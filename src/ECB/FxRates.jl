using HTTP, CSV, Dates, ZipFile

function ECB_FxRates(from::Date; dir::String="")

    file = HTTP.get("https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.zip").body
    #download("https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.zip") Usar download para eliminar la dependencia de HTTP?
    r = ZipFile.Reader(IOBuffer(file))

    FxHist = CSV.read(r.files[1], dateformat="yyyy-mm-dd",delim=',',quotechar='"',missingstring="N/A")

    FxHist = FxHist[FxHist[:,1].>=from,:]

    dir !="" && CSV.write(dir*"/tDivisa.csv",FxHist,delim=";",decimal=',')

    FxHist
end