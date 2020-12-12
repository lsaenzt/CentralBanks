
function saveCSV(Files::Dict)

    for (name,df) in BdE_Files
      writeCSVTransposed(sort(df, 1,rev=true),name)
    end
  
  end

function writeCSVTransposed(df::DataFrame,filename::AbstractString)
    #Lee el dataframe, los transpone y graba en un csv codificado de forma que excel lea los acentos bien...
    
    UTF8_IO = IOBuffer()
    transposed_IO = IOBuffer()

    CSV.write(UTF8_IO,df, delim=";", quotestrings=true) #Utilizo ";" porque la descripción de lo campos pueden tener "," y hace que la lectura falle. Además excel los coge mejor

    try 
        CSV.write(transposed_IO,CSV.read(seekstart(UTF8_IO),delim=";",transpose=true),delim=";",quotestrings=true) #Leo PyG_Sector transpuesta y la vuelvo a escribir -> Mejorable...
        file = open(filename*".csv","w")
        encoder = StringEncoder(file,enc"Latin1")
        write(encoder,read(seekstart(transposed_IO),String))
        close(encoder) #codifica el stream de datos en Latin1
        close(file) #graba el stream de datos
    catch
        @warn "Could not write file."
    end

end #function