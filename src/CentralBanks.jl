module CentralBanks

using CSV, StringEncodings #El fichero de BdE está en Latin1 no UTF8
using Dates
using DataFrames
using HTTP, ZipFile

cd(@__DIR__)

include("src/BdEStats/capítulo4.jl")
include("src/BdEStats/capítulo2.jl")
include("src/BdEStats/capítulo19.jl")
include("src/BdEStats/InterestRates.jl")
include("src/ECBStats/FxRates.jl")
include("src/utilidades.jl")

end #module