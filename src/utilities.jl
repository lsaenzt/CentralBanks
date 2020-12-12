function saveCSV(BdE_Files::Dict)

    for (name,df) in BdE_Files
      writeCSVTransposed(sort(df, 1,rev=true),name)
    end
  
end

#TODO: make latin1 encoding an independent function
function transposedf(df::DataFrame,; columna1::Symbol = :Concepto)

    DataFrame([[names(df[:,2:end])]; collect.(eachrow(df[:,2:end]))], [columna1;Symbol.(df[:,1])])

end #function

function writeCSVTransposed(df::DataFrame,filename::AbstractString; columna1::Symbol = :Concepto)
    # Reads a latin1 econded dataframe, transposes it for P&L format and saves a csv that is easy to read from excel
    
    UTF8_IO = IOBuffer()
 
    CSV.write(UTF8_IO,transposedf(df,columna1=columna1), delim=";", quotestrings=true) #  ";" as delimiter because some field descriptions in BdE info can have ","

    try 
        file = open(filename*".csv","w")
        encoder = StringEncoder(file,enc"Latin1")
        write(encoder,read(seekstart(traUTF8_IO),String))
        close(encoder) #encodes the data stream into Latin1
        close(file) #saves the data stream
    catch
        @warn "Could not write file."
    end

end #function

