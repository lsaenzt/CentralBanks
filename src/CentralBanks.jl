module CentralBanks

using CSV, StringEncodings #El fichero de BdE está en Latin1 no UTF8
using Dates
using DataFrames
using HTTP,ZipFile
#using XLSX

cd("//datos02/9763-AnalisisyPlanificacion_Financiera/7. Mercado/CentralBanks")

include("BdEStats/capítulo4.jl")
include("BdEStats/InteresRates.jl")
include("ECBStats/FxRates.jl")

include("BdEStats/utilidades.jl")

end #module

using EurCentralBanks

BdE_be04("//datos02/9763-AnalisisyPlanificacion_Financiera/7. Mercado/Sector",Dates.Date(2005))
BdE_tiposInteres("//datos02/9763-AnalisisyPlanificacion_Financiera/7. Mercado/Tipos",Dates.Date(2005))
ECB_FxRates("//datos02/9763-AnalisisyPlanificacion_Financiera/7. Mercado/Tipos",Dates.Date(2005))
