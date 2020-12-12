module CentralBanks

using CSV, StringEncodings #El fichero de BdE está en Latin1 no UTF8
using Dates
using DataFrames
using HTTP, ZipFile

cd(@__DIR__)

include("Spain/boletinEstadistico.jl")
include("Spain/InterestRates.jl")
include("ECB/FxRates.jl")
include("utilidades.jl")

end #module