export FxRates

#TODO. Dividir la descarga y la generaración y grabación del dataframe

function ECB_FxRates(ruta::String,from::Date)

    file = HTTP.get("https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.zip").body
    r = ZipFile.Reader(IOBuffer(file))

    FxHist = CSV.File(r.files[1], dateformat="yyyy-mm-dd",delim=',',quotechar='"',missingstring="N/A") |> DataFrame

    FxHist = FxHist[FxHist[:,1].>=from,:]

    CSV.write(ruta*"/tDivisa.csv",FxHist,delim=";",decimal=',')

    FxHist
end