function BdE_InterestRates(from::Date; ruta::String="") 

    #Descarga de ficheros desde la página del Banco de España
    tempIO=IOBuffer()
    file = HTTP.get("https://www.bde.es/webbde/es/estadis/infoest/series/ti_1_7.csv").body
    write(tempIO,file)
      #Definición de formato de fechas utilizado por Banco de España en su boletín estadístico
    bde_months = ["ENERO", "FEBRERO", "MARZO", "ABIRL", "MAYO", "JUNIO", "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"]
    bde_monts_abbrev = ["ENE","FEB","MAR","ABR","MAY","JUN", "JUL","AGO","SEP","OCT","NOV","DIC"]

    Dates.LOCALES["BdE"] = Dates.DateLocale(bde_months,bde_monts_abbrev, [""],[""],)

    BdE_Format = DateFormat("dd uuuyyyy", "BdE") #Definición del formato de fechas utilizado por BdE

    #Lectura fichero transformando Latin1 a UTF8
    IntHist = CSV.read(read(StringDecoder(seekstart(tempIO), enc"Latin1")), header=3, datarow=5, delim=',',decimal='.',quotechar='"',
                      missingstrings=["...","_"], dateformat=BdE_Format)

    IntHist = IntHist[(IntHist[:,1]).>=from,:]
    sort!(IntHist,1,rev=true)

    ruta !="" && begin
      UTF8_IO = IOBuffer()
      CSV.write(UTF8_IO,IntHist, delim=';',decimal=',',quotestrings=true)
      file = open(ruta*"/tInteres.csv","w")
      encoder = StringEncoder(file, enc"Latin1")
      write(encoder,read(seekstart(UTF8_IO),String))
      close(encoder) #codifica el stream de datos en Latin1
      close(file) #graba el stream de datos
    end

    IntHist
end