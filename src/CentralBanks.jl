module CentralBanks

using CSV, StringEncodings #El fichero de BdE está en Latin1 no UTF8
using Dates
using DataFrames
using HTTP, ZipFile

dir = @__DIR__

include(joinpath(dir,"src/Spain/boletinEstadistico.jl"))
include(joinpath(dir,"src/Spain/Rates.jl"))
include(joinpath(dir,"src/Spain/utilities.jl"))

include(joinpath(dir,"src/ECB/FxRates.jl"))
include(joinpath(dir,"src/utilities.jl"))

end #module