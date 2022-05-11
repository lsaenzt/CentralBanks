using HTTP, CSV, JSON3, StructTypes
using JSONStat

"""Downloads a all datasets in a domain"""
function downloaddataset(domain::Int, directory::String;
                         dataset::Union{Nothing,Int}=nothing)

    info = domaindetail(domain; lang="PT")
    isnothing(dataset) ? datasetnum = info.num_datasets : datasetnum = dataset
    pagesize = min(100, info.num_series) # API does not accept more than 100 series per page_size
    pagenum = divrem(info.num_series, 100)
    f = info.label

    isdir(directory) || mkdir(directory)  # Si no hay directorio lo creamos

    for dᵢ in 1:datasetnum # A domain can have several datasets
        if datasetnum == 1
            io = open(joinpath(directory, string(f, ".csv")), "w") # Open file
        else
            io = open(joinpath(directory, string(f, "_ds", dᵢ, ".csv")), "w") # Open file
        end
        url = domaindatasets(domain).link.item[dᵢ].href
        ds = HTTP.get(string(url, "&page_size=", pagesize, "&page=1")).body
        pᵢ = 1
        while true # A big dataset is served in several 'pages'
            js = JSON3.read(ds)
            dt = JSONStat.read(ds)
            (pᵢ == 1) ? CSV.write(io, dt; delim=";", decimal=',', transform=(col, val) -> something(val, missing)) : CSV.write(io, dt; delim=";", decimal=',', append=true, transform=(col, val) -> something(val, missing)) # First page opens, next appends
            haskey(js.extension, :next_page) ? begin url = js.extension.next_page; pᵢ += 1 end : break 
            ds = HTTP.get(url).body
        end
        close(io)
    end
end

"""Downloads a specfic set of series provided as a character-separated-values string. The series MUST belong to the same dataset"""
function downloadseries(series_id::String, directory::String; file::String="file")

    series = seriesdetails(series_id; lang="EN")
    dataset = series[1].dataset_id 
    domain = series[1].domain_ids[1]

    for i in series
       (i.dataset_id != dataset) && error("Series must belong to the same dataset")
    end

    dataset = HTTP.get(bpstat_API_URL * "/domains/"*string(domain)*"/datasets/"*dataset*
                    "/?lang=EN&series_ids=" * series_id).body

    rw = JSONStat.read(dataset)

    isdir(directory) || mkdir(directory) # Si no hay directorio lo creamos

    io = open(joinpath(directory, file * ".csv"), "w")
    CSV.write(io, rw; delim=";",decimal=',',transform=(col, val) -> something(val, missing))
    return close(io)
end

# Friendly domain id, domain name printout
function listdomains()
    d = domains()
    for dᵢ in d
        println(dᵢ["id"], " ", dᵢ["label"])
    end
end

# Interface for BPStat Data API

const bpstat_API_URL = "https://bpstat.bportugal.pt/data/v1"

#-------------------------------------------------------------------------------------------------------------------------
# List Domains Endpoint
#-------------------------------------------------------------------------------------------------------------------------

function domains(; lang::String="EN")
    return JSON3.read(HTTP.get(bpstat_API_URL * "/domains/?lang=" * lang).body)
end

#-------------------------------------------------------------------------------------------------------------------------
# Domain Detail Endpoint
#-------------------------------------------------------------------------------------------------------------------------

function domaindetail(id::Int; lang::String="EN")
    return JSON3.read(HTTP.get(bpstat_API_URL * "/domains/" * string(id) * "/?lang=" * lang).body)
end

#-------------------------------------------------------------------------------------------------------------------------
# List domain datasets Endpoint
#-------------------------------------------------------------------------------------------------------------------------

function domaindatasets(id::Int; lang::String="EN")
    return JSON3.read(HTTP.get(bpstat_API_URL * "/domains/" * string(id) * "/datasets/?lang=" * lang*"&page_size=25").body)
end

#-------------------------------------------------------------------------------------------------------------------------
# Get Dataset (Observations) Endpoint
#-------------------------------------------------------------------------------------------------------------------------

function dataset(domain::Int; lang::String="EN", pagesize::Int=10, dataset::Int=1)
    
    domaindetail(domain)[Symbol("has_series")] == false &&
        return error("Selected Dataset has no series")

    url = domaindatasets(domain; lang).link.item[dataset].href
    return JSON3.read(HTTP.get(url * "&page_size=" * string(pagesize)).body)
end

#-------------------------------------------------------------------------------------------------------------------------
# List series details Endpoint
#-------------------------------------------------------------------------------------------------------------------------

function seriesdetails(series::String; lang::String="EN")
    return JSON3.read(HTTP.get(bpstat_API_URL * "/series/?lang=" * lang*"&series_ids="*series).body)
end
