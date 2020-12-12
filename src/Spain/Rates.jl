function downloadInterestRates(directory::String) 

    #Descarga de ficheros desde la página del Banco de España
    file = HTTP.get("https://www.bde.es/webbde/es/estadis/infoest/series/ti_1_7.csv").body
    
    isdir(joinpath(directory,"tipos")) || mkdir(joinpath(directory,"tipos")) # Si no hay directorio lo creamos

    io = open(joinpath(directory,"tipos","tInteres.csv"),"w")
    write(io,file)
    close(io)
    
end