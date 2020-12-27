"""
    CSVtoDataFrame(directory::String)

Read all the Boletin Estadístico files in a directory, tranform them into a DataFrame. 
Return a Dictionary with pairs (filename, dataframe)

"""
function CSVtoDataFrame(directory::String,from::Date=Date(1900))

    #Definición de formato de fechas utilizado por Banco de España en su boletín estadístico
    bde_months = ["ENERO", "FEBRERO", "MARZO", "ABIRL", "MAYO", "JUNIO", "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"]
    bde_monts_abbrev = ["ENE","FEB","MAR","ABR","MAY","JUN", "JUL","AGO","SEP","OCT","NOV","DIC"]

    Dates.LOCALES["BdE"] = Dates.DateLocale(bde_months,bde_monts_abbrev, [""],[""],)

    BdE_MonthYear = DateFormat("uuu yyyy", "BdE") #Definición del formato de fechas utilizado por BdE
    BdE_DayMonthYear = DateFormat("dd uuu yyyy", "BdE")

    File_Dict = Dict{String,DataFrame}() #Inicializo el Diccionario con los datos

    #Lectura datos ficheros BdE. La carpeta debe estar en una carpeta llamada "be04"
    for file in readdir(directory)

        #Lectura fichero transformando Latin1 a UTF8      
        tempdf = CSV.File(open(read,joinpath(directory,file), enc"Latin1"), header=4, datarow=7, footerskip=2, delim=',',
                        decimal='.',quotechar='"',missingstrings=["_","..."]) |> DataFrame
        
        #Conversión de datos (distinguiendo cuando hay año, mes y año, día, mes y año)        
        if typeof(tempdf[1,1])== Int 
           tempdf[!,1] = Date.(tempdf[:,1],12,31)
        
        elseif isdigit(tempdf[1,1][1])
            tempdf[!,1] = Date.(tempdf[:,1],BdE_DayMonthYear)

        elseif typeof(tempdf[1,1])==String 
            tempdf[!,1] = lastdayofmonth.(Date.(tempdf[:,1],BdE_MonthYear))

        end     
        
        #Filtrado por fecha según from
        tempdf = tempdf[(tempdf[:,1]).>=from,:]
           
        #Creación de Dict para guardar cada dataframe asociado al nombre del fichero según Banco de España
        filename = file[1:length(file)-4]
        push!(File_Dict,filename => tempdf)

    end #for

    File_Dict

end
"""
Transpose a Dataframe
"""

function transposedf(df::DataFrame; columna1::Symbol = :Concepto)

    DataFrame([[names(df[:,2:end])]; collect.(eachrow(df[:,2:end]))], [columna1;Symbol.(df[:,1])])

end #function

"""

Graba un dataframe con codificación latin1 para capturar correctamente los caracteres de un fichero de Banco de España

"""

function DataFrametoCSV(df::DataFrame, directory::String, filename::String)

    UTF8_IO = IOBuffer()

    CSV.write(UTF8_IO,df, delim=';',decimal=',',quotestrings=true)

    file = open(joinpath(directory,filename),"w")    
    encoder = StringEncoder(file, enc"Latin1")

    write(encoder,read(seekstart(UTF8_IO),String))
    close(encoder) #codifica el stream de datos en Latin1
    close(file) #graba el stream de datos

end
