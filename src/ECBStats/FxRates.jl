using HTTP
using CSV
using Dates
using ZipFile

function ECB_FxRates(ruta::String,from::Date)

    file = HTTP.get("https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.zip").body
    r = ZipFile.Reader(IOBuffer(file))

    FxHist = CSV.read(r.files[1], dateformat="yyyy-mm-dd",delim=',',quotechar='"',missingstring="N/A")

    FxHist = FxHist[FxHist[:,1].>=from,:]

    CSV.write(ruta*"/tDivisa.csv",FxHist,delim=";",decimal=',')

    FxHist
end