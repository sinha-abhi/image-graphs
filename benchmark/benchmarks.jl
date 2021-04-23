using BenchmarkTools

using FileIO
using LinearAlgebra
using NRRD
using Printf

using IM2GR
import IM2GR: __default_diff_fn

BenchmarkTools.DEFAULT_PARAMETERS.seconds = 300 

function bm_singlethread(data, d, f, diff_fn=__default_diff_fn) 
  println("Running once to compile...")
  im2gr(data, d, IM2GR.CM_SingleThread, diff_fn)
  println("Running benchmarks...")
  b = @benchmarkable im2gr($data, $d, IM2GR.CM_SingleThread, $diff_fn)
  bret = run(b)
  res = open(f, "w+")
  show(res, MIME"text/plain"(), bret)

  nothing
end

function bm_multithread(data, d, f, diff_fn=__default_diff_fn)
  println("Running once to compile...")
  im2gr(data, d, IM2GR.CM_MultiThread, diff_fn)
  println("Running benchmarks...")
  b = @benchmarkable im2gr($data, $d, IM2GR.CM_MultiThread, $diff_fn)
  bret = run(b)
  res = open(f, "w+")
  show(res, MIME"text/plain"(), bret)

  nothing
end

function bm_cuda(data, d, f, diff_fn=__default_diff_fn)
  println("Running once to compile...")
  im2gr(data, d, IM2GR.CM_CUDA, diff_fn)
  println("Running benchmarks...")
  b = @benchmarkable im2gr($data, $d, IM2GR.CM_CUDA, $diff_fn)
  bret = run(b)
  res = open(f, "w+")
  show(res, MIME"text/plain"(), bret)

  nothing
end


mri_diff_fn(xi, xj) = min(sqrt(xi) / 63, 1.0) - min(sqrt(xj) / 63, 1.0)
mri = load("data/lgemri.nrrd")

fake = rand(UInt8, (144, 144, 22))

bm_singlethread(mri, 1, "benchmark/st-mri-unimodular.txt", mri_diff_fn)
bm_singlethread(fake, 1, "benchmark/st-fake-unimodular.txt")

bm_multithread(mri, 1, "benchmark/mt-mri-unimodular.txt", mri_diff_fn)
bm_multithread(fake, 1, "benchmark/mt-fake-unimodular.txt")

#bm_cuda(mri, 1, "benchmark/cuda-mri-unimodular.txt", mri_diff_fn)
bm_cuda(fake, 1, "benchmark/cuda-fake-unimodular.txt")

