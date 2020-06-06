module CentralBanks

using CSV, StringEncodings #El fichero de BdE está en Latin1 no UTF8
using Dates
using DataFrames
using HTTP,ZipFile
#using XLSX

include("Spain/capítulo4.jl")
include("Spain/interestRates.jl")
include("ECB/FxRates.jl")
include("utilities.jl")

end #module

using Main.CentralBanks, Dates

BdE_be04("//datos02/9763-AnalisisyPlanificacion_Financiera/7. Mercado/Sector",Dates.Date(2005))
CentralBanks.interestRates(Dates.Date(2010))
CentralBanks.ECB_FxRates(Dates.Date(2012))