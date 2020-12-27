"""
    downloadchapter(chapter, dir)

Downloads and unzips a complete chapter from Boletin Estadístico of Bank of Spain

Creates a subfolder with the name of the chapter if it does not exists already

# Example

    downloadchapter(2, "C:\\Users\\Weyland\\Documents\\") 
"""

function downloadchapter(capitulo::Int, directory::String) 

    n = lpad(capitulo,2,"0")

    #TODO: sustituir por Downloads en base con 1.6 
    #Descarga de ficheros desde la página del Banco de España. Cambiar por 
    file = HTTP.get("https://www.bde.es/webbde/es/estadis/infoest/series/be"*n*".zip").body
    r = ZipFile.Reader(IOBuffer(file));

    isdir(joinpath(directory,"be"*n)) || mkdir(joinpath(directory,"be"*n)) # Si no hay directorio lo creamos

    for f in r.files
        println("Filename: $(f.name)")
        io = open(joinpath(directory,"be"*n,f.name),"w") #Creación de fichero con nombre igual al del ZIP
        write(io,read(f))
        close(io)
    end
    close(r)

end #function

"""
downloadchapter(f, chapter, dir)

Downloads and unzips a complete chapter from Boletin Estadístico of Bank of Spain. 
Then applies a function that acts on the files on the same directory

# Example

    downloadchapter(CSVtoDataFrame, 2, "C:\\Users\\Weyland\\Documents\\") 

"""
function downloadchapter(f::Function, capitulo::Int, directory::String) 

    downloadchapter(capitulo::Int, directory::String) 
    
    f(joinpath(directory,"be"*lpad(capitulo,2,"0")))
    
end #function
