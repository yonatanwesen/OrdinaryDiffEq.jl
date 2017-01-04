type DEOptions{uEltype,uEltypeNoUnits,tTypeNoUnits,tType,F2,F3,F4,F5,tstopsType,ECType}
  maxiters::Int
  timeseries_steps::Int
  save_timeseries::Bool
  adaptive::Bool
  abstol::uEltype
  reltol::uEltypeNoUnits
  gamma::tTypeNoUnits
  qmax::tTypeNoUnits
  qmin::tTypeNoUnits
  dtmax::tType
  dtmin::tType
  internalnorm::F2
  tstops::tstopsType
  saveat::tstopsType
  userdata::ECType
  progress::Bool
  progress_steps::Int
  progress_name::String
  progress_message::F5
  beta1::tTypeNoUnits
  beta2::tTypeNoUnits
  qoldinit::tTypeNoUnits
  dense::Bool
  callback::F3
  isoutofdomain::F4
  calck::Bool
  advance_to_tstop::Bool
end

type ODEIntegrator{algType<:OrdinaryDiffEqAlgorithm,uType<:Union{AbstractArray,Number},tType,tTypeNoUnits,ksEltype,SolType,rateType,F,ProgressType,CacheType,O} <: AbstractODEIntegrator
  sol::SolType
  u::uType
  k::ksEltype
  t::tType
  dt::tType
  f::F
  uprev::uType
  kprev::ksEltype
  tprev::tType
  adaptiveorder::Int
  order::Int
  alg::algType
  rate_prototype::rateType
  notsaveat_idxs::Vector{Int}
  calcprevs::Bool
  dtcache::tType
  dtpropose::tType
  dt_mod::tTypeNoUnits
  tdir::Int
  qminc::tTypeNoUnits
  qmaxc::tTypeNoUnits
  EEst::tTypeNoUnits
  qold::tTypeNoUnits
  iter::Int
  saveiter::Int
  saveiter_dense::Int
  prog::ProgressType
  cache::CacheType
  kshortsize::Int
  reeval_fsal::Bool
  opts::O
  fsalfirst::rateType
  fsallast::rateType

  ODEIntegrator(sol,u,k,t,dt,f,uprev,kprev,tprev,adaptiveorder,
    order,alg,rate_prototype,notsaveat_idxs,calcprevs,dtcache,dtpropose,dt_mod,tdir,qminc,
      qmaxc,EEst,qold,iter,saveiter,saveiter_dense,prog,cache,
      kshortsize,reeval_fsal,opts) = new(
    sol,u,k,t,dt,f,uprev,kprev,tprev,adaptiveorder,
      order,alg,rate_prototype,notsaveat_idxs,calcprevs,dtcache,dtpropose,dt_mod,tdir,qminc,
      qmaxc,EEst,qold,iter,saveiter,saveiter_dense,prog,cache,
      kshortsize,reeval_fsal,opts) # Leave off fsalfirst and last
end
