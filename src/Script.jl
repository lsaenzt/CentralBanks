using Dates, .CentralBanks

CentralBanks.ECB_FxRates("//datos02/9763-AnalisisyPlanificacion_Financiera/D. Datos/7. Tipos", Dates.Date(2005))

CentralBanks.downloadchapter(4,"c:\\Users\\Luis\\OneDrive\\Documents\\JuliaProjects\\CentralBanks")
CentralBanks.downloadchapter(2,"c:\\Users\\Luis\\OneDrive\\Documents\\JuliaProjects\\CentralBanks")
CentralBanks.downloadchapter(19,"c:\\Users\\Luis\\OneDrive\\Documents\\JuliaProjects\\CentralBanks")

CentralBanks.downloadInterestRates("c:\\Users\\Luis\\OneDrive\\Documents\\JuliaProjects\\CentralBanks")
dfs = CentralBanks.CSVtoDataFrame("c:\\Users\\Luis\\OneDrive\\Documents\\JuliaProjects\\CentralBanks\\tipos",Date(2005))
sort!(dfs["tInteres"], 1,rev = true) # Va a fallar porque no está el using DataFrame
CentralBanks.DataFrametoCSV(dfs["tInteres"], "c:\\Users\\Luis\\OneDrive\\Documents\\JuliaProjects\\CentralBanks\\tipos","tinteres.csv")

CentralBanks.combinaciones(ans)