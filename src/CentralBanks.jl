module CentralBanks

using CSV, StringEncodings #El fichero de BdE está en Latin1 no UTF8
using Dates
using DataFrames
using HTTP, ZipFile

dir = @__DIR__

include(joinpath(dir,"Spain/boletinEstadistico.jl"))
include(joinpath(dir,"Spain/Rates.jl"))
include(joinpath(dir,"ECB/FxRates.jl"))
include(joinpath(dir,"utilidades.jl"))

end #module