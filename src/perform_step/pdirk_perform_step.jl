function initialize!(integrator, cache::PDIRK44ConstantCache) end

@muladd function perform_step!(integrator, cache::PDIRK44ConstantCache, repeat_step=false)

end

function initialize!(integrator, cache::PDIRK44Cache) end

@muladd function perform_step!(integrator, cache::PDIRK44Cache, repeat_step=false)
  @unpack t,dt,uprev,u,f,p,alg = integrator
  @unpack nlsolver,k1,k2,tab = cache
  @unpack γs,cs,α1,α2,b1,b2,b3,b4 = tab
  if alg.threading == true
    let nlsolver=nlsolver, u=u, uprev=uprev, integrator=integrator, cache=cache, dt=dt, repeat_step=repeat_step,
      k1=k1
      Threads.@threads for i in 1:2
        nlsolver[i].z .= zero(eltype(u))
        nlsolver[i].tmp .= uprev
        indexed_update_W!(integrator, cache, γs[i]*dt, i, repeat_step)
        nlsolver[i].γ = γs[i]
        nlsolver[i].c = cs[i]
        k1[i] .= DiffEqBase.nlsolve!(nlsolver[i], nlsolver[i].cache, integrator)
      end
    end
    nlsolvefail(nlsolver[1]) && return
    nlsolvefail(nlsolver[2]) && return
    let nlsolver=nlsolver, u=u, uprev=uprev, integrator=integrator, cache=cache, dt=dt, repeat_step=repeat_step,
      k1=k1, k2=k2
      Threads.@threads for i in 1:2
        nlsolver[i].c = cs[2+i]
        nlsolver[i].z .= zero(eltype(u))
        @.. nlsolver[i].tmp = uprev + α1[i] * k1[1] + α2[i] * k1[2]
        k2[i] .= DiffEqBase.nlsolve!(nlsolver[i], nlsolver[i].cache, integrator)
      end
    end
    nlsolvefail(nlsolver[1]) && return
    nlsolvefail(nlsolver[2]) && return
  else
    _nlsolver = nlsolver[1]
    _nlsolver.z .= zero(eltype(u))
    indexed_update_W!(integrator, cache, γs[1]*dt, 1, repeat_step)
    _nlsolver.tmp .= uprev
    _nlsolver.γ = γs[1]
    _nlsolver.c = cs[1]
    k1[1] .= DiffEqBase.nlsolve!(_nlsolver, _nlsolver.cache, integrator)
    nlsolvefail(_nlsolver) && return
    _nlsolver.z .= zero(eltype(u))
    indexed_update_W!(integrator, cache, γs[2]*dt, 1, repeat_step)
    _nlsolver.tmp .= uprev
    _nlsolver.γ = γs[2]
    _nlsolver.c = cs[2]
    k1[2] .= DiffEqBase.nlsolve!(_nlsolver, _nlsolver.cache, integrator)
    nlsolvefail(_nlsolver) && return
    _nlsolver.z .= zero(eltype(u))
    indexed_update_W!(integrator, cache, γs[1]*dt, 1, repeat_step)
    @.. _nlsolver.tmp .= uprev + α1[1] * k1[1] + α2[1] * k1[2]
    _nlsolver.γ = γs[1]
    _nlsolver.c = cs[3]
    k2[1] .= DiffEqBase.nlsolve!(_nlsolver, _nlsolver.cache, integrator)
    nlsolvefail(_nlsolver) && return
    _nlsolver.z .= zero(eltype(u))
    indexed_update_W!(integrator, cache, γs[2]*dt, 1, repeat_step)
    @.. _nlsolver.tmp = uprev + α1[2] * k1[1] + α2[2] * k1[2]
    _nlsolver.γ = γs[2]
    _nlsolver.c = cs[4]
    k2[2] .= DiffEqBase.nlsolve!(_nlsolver, _nlsolver.cache, integrator)
    nlsolvefail(_nlsolver) && return
  end
  @.. u = uprev + b1 * k1[1] + b2 * k2[1] + b3 * k1[2] + b4 * k2[2]
end