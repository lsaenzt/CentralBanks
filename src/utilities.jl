
function saveCSV(Files::Dict)

    for (name,df) in BdE_Files
      writeCSVTransposed(sort(df, 1,rev=true),name)
    end
  
  end

#TODO: make latin1 encoding an independent function

function writeCSVTransposed(df::DataFrame,filename::AbstractString)
    # Reads a latin1 econded dataframe, transposes it for P&L format and saves a csv that is easy to read from excel
    
    UTF8_IO = IOBuffer()
    transposed_IO = IOBuffer()

    CSV.write(UTF8_IO,df, delim=";", quotestrings=true) #  ";" as delimiter because some field descriptions in BdE info can have ","

    try 
        CSV.write(transposed_IO,CSV.read(seekstart(UTF8_IO),delim=";",transpose=true),delim=";",quotestrings=true) # TODO: post question in discourse there must be a better way
        file = open(filename*".csv","w")
        encoder = StringEncoder(file,enc"Latin1")
        write(encoder,read(seekstart(transposed_IO),String))
        close(encoder) #encodes the data stream into Latin1
        close(file) #saves the data stream
    catch
        @warn "Could not write file."
    end

end #function
