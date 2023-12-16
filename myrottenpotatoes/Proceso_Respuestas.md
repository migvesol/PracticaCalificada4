# Proceso y Respuestas de la Actividad

Clonamos el respotorio dado en la actividad y nos dirigimos al siguiente directorio de myrottenpotatoes y ejecutamos el comando `bin/rails server` para iniciar nuestro servidor web local que escucha en un puerto específico (por defecto, el puerto 3000), acedemos a nuestra aplicación a través de un navegador web visitando http://localhost:3000, nos muestra un error, ActiveRecord::StatementInvalid nos indica que hay un problema con una consulta SQL en nuestra aplicación Rails.

![2](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/1727abfa-82d2-464c-b6de-af1aba732084)



Por tal motivo al dirigirnos a la terminal nos muestra 500 Internal Server Error que es un código de respuesta de error del servidor que indica que el servidor encontró una condición inesperada que le impidió cumplir con la solicitud debido a que estámos intentando acceder a la tabla moviegoers y Rails no la encuentra en la base de datos. Ademas el error sugiere que el problema está en el método set_current_user ubicado en el archivo Desarrollo-software-2023/Semana7/myrottenpotatoes/app/controllers/application_controller.rb

![3](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/8f7c2696-a34c-4a54-ac31-94209d8b4b09)

Al movernos a la carpeta migrate en el directorio db vemos que tenemos un archivo de migración denominado 20231003234846_create_movies.rb. Escribimos el comando rails generate migration CreateMoviegoers para generar un nuevo archivo de migración en el directorio db/migrate con un esquema básico para crear la tabla moviegoers. El nombre del archivo se generará automáticamente y contendrá una marca de tiempo para garantizar un orden correcto de ejecución de migraciones.

![5](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/19eb9829-b8fa-45ae-915a-f0ad00764e85)

Sin embargo, todavia no hemos ejecutado la migración para aplicar los cambios a la base de datos, para ellos debemos ejecutar el comando `rails db:migrate.

![8](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/9b1910ce-ec48-4641-88e0-b4f774257ae4)

Observamos el archivo schema.rb que contiene información sobre la estructura de la base de datos, incluyendo las tablas y sus columnas. Este archivo se genera automáticamente a partir de las migraciones y refleja el estado actual de la base de datos. Podemos observar en la siguiente imagen que tenemos dos tablas, entre ellas la tabla moviegoer y con ello solucionariamos el error anterior.

![9](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/9ee6796b-d53c-41cd-9d1d-e9c87f84942d)

Ejecutamos el comando bin/rails server nuevamente y notamos un nuevo error, esta vez relacionado a un error de sintaxis en el archivo app/models/movie.rb, esto se puede apreciar en la siguiente imagen.

![10](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/21d333b5-434f-46ed-a9fe-50ef806d38a2)

Lo solucionamos editando el archivo movie.rb, quedandonos de la siguiente manera.

![11](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/9077b67d-c2c6-4d13-9b64-cbd5acc81adc)


Ejecutamos el comando bin/rails server y podemos ver la siguiente vista  a traves de un navegador web, esta vista lo maneja los archivos index.html.haml (representa la vista de la lista de todas las películas), new.html.haml (se utiliza para mostrar el formulario de creación de una nueva película), show.html.haml (.muestra los detalles de una película específica). Estas vistas son componentes esenciales para la interacción del usuario con la aplicación.

![13](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/c0600d41-df01-4b6a-a22c-e09cddbe0297)

Las validaciones en Rails son mecanismos que permiten asegurar que los datos almacenados en la base de datos cumplen con ciertos criterios antes de ser guardados.Si una validación falla, el objeto no se guardará y se agregarán errores al objeto para indicar qué validaciones fallaron y por qué. Estas validaciones ayudan a mantener la integridad, seguridad, la experiencia del usuario, el mantenimiento de las reglas de negocio y la consistencia de los datos en la aplicación.

Por ello, para estudiar este mecanismo editaremos el archivo `movie.rb` con el siguiente codigo:

```
class Movie < ActiveRecord::Base
    def self.all_ratings ; %w[G PG PG-13 R NC-17] ; end #  shortcut: array of strings
    validates :title, :presence => true
    validates :release_date, :presence => true
    validate :released_1930_or_later # uses custom validator below
    validates :rating, :inclusion => {:in => Movie.all_ratings},
        :unless => :grandfathered?
    def released_1930_or_later
        errors.add(:release_date, 'must be 1930 or later') if
        release_date && release_date < Date.parse('1 Jan 1930')
    end
    @@grandfathered_date = Date.parse('1 Nov 1968')
    def grandfathered?
        release_date && release_date < @@grandfathered_date
    end
end

```
Ejecutamos el comando rails console y comprobamos los resultados creando una nueva instancia de la clase Movie con atributos específicos, incluyendo un título en blanco (''), una clasificación ('RG'), y una fecha de lanzamiento anterior a 1930 ('1929-01-01').

![19](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/45d3b1b9-63f4-4d13-9a4d-3b3cc3fe1e6f)


Explica el código siguiente :

```
class MoviesController < ApplicationController
  def new
    @movie = Movie.new
  end 
  def create
    if (@movie = Movie.create(movie_params))
      redirect_to movies_path, :notice => "#{@movie.title} created."
    else
      flash[:alert] = "Movie #{@movie.title} could not be created: " +
        @movie.errors.full_messages.join(",")
      render 'new'
    end
  end
  def edit
    @movie = Movie.find params[:id]
  end
  def update
    @movie = Movie.find params[:id]
    if (@movie.update_attributes(movie_params))
      redirect_to movie_path(@movie), :notice => "#{@movie.title} updated."
    else
      flash[:alert] = "#{@movie.title} could not be updated: " +
        @movie.errors.full_messages.join(",")
      render 'edit'
    end
  end
  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    redirect_to movies_path, :notice => "#{@movie.title} deleted."
  end
  private
  def movie_params
    params.require(:movie)
    params[:movie].permit(:title,:rating,:release_date)
  end
end
```
 Este controlador sigue las convenciones de Rails y proporciona las acciones necesarias para realizar operaciones CRUD (Crear, Leer, Actualizar, Eliminar) en el modelo de películas.

Editamos el archivo movie.rb y comprobamos que el siguiente codigo ilustra cómo utilizar este mecanismo para “canonicalizar” (estandarizar el formato de) ciertos campos del modelo antes de guardar el modelo.

```
class Movie < ActiveRecord::Base
    before_save :capitalize_title
    def capitalize_title
        self.title = self.title.split(/\s+/).map(&:downcase).map(&:capitalize).join(' ')
    end
end

```
Con lo cual el metodo `capitalize_title` se encargará de dividir las palabras en el título, convertirlas a minúsculas y luego capitalizar la primera letra de cada palabra antes de unirlas nuevamente. Ejecutamos el comando rails console y comprobamos los resultados creando una nueva instancia de la clase Movie con atributos específicos, incluyendo un título ('STAR wars'), una fecha de lanzamiento ('127-5-1977) y una clasificación ('PG'). Al escribir m.title en la consola deberiamos ver que el título se ha estandarizado y capitalizado como "Star Wars".

![21](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/a15055a8-9fb3-44ea-94c9-709738121e07)

Ejecutamos bin/rails server y podemos apreciar qie se agrego un nuevo registro en la tabla de peliculas.

```
Star Wars 	PG 	1977-05-27 00:00:00 UTC 	More about Star Wars

```

## SSO y autenticación a través de terceros

Una manera de ser más DRY y productivo es evitar implementar funcionalidad que se puede reutilizar a partir de otros servicios. Un ejemplo muy actual de esto es la autenticación.

Afortunadamente, añadir autenticación en las aplicaciones Rails a través de terceros es algo directo. Por supuesto, antes de que permitamos iniciar sesión a un usuario, ¡necesitamos poder representar usuarios! Así que antes de continuar, vamos a crear un modelo y una migración básicos siguiendo las instrucciones.

 Al continuar con la realizacion  de la actividad tenemos las siguiente instruccion `rails generate model Moviegoer name:string provider:string uid:string`, sin embargo hay un conflicto(debido al nombre 'Moviegoer' que ya se utiliza en nuestra aplicación) con el archivo  `db/migrate/20231114214700_create_moviegoers.rb` realizada anteriormente, por ello realicè el comando `rails generate model Moviegoer name:string provider:string uid:string --skip-collision-check --force`, con lo cual eliminamos el archivo de migración anterior, es decir `20231113195135_create_moviegoers.rb`, creamos un nuevo archivo de migración `db/migrate/20231114214754_create_moviegoers.rb` y sobrescribimos el archivo del modelo Moviegoer. Para evitar futuros errores o conflictos, elimine la base de datos  y la cree nuevamente.

![28](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/57e85776-c0eb-461b-9e9a-76855d3950d4)

Editamos el archivo schema.rb donde se almacena la estructura actual de la base de datos para que se encuentra con la version `2023_10_03_234846`, es decir, previo a la clonacion del repositoio, luego ejecutamos el comando `rails db:migrate` para crear la tabla moviegoeres e incorporarla al archivo y darle la version al schema de esta ultima migracion como se puede apreciar en su marca de tiempo dada en la siguiente imagen.


 ![32](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/d1b51a99-3469-4dc3-a73c-7d39fe963ecb)

Sin embargo, la base de datos actual esta vacia debido a que no hemos incorporado las semillas dadas en el archivo seeds.rb.

![31](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/01f8ef61-7af2-4782-8473-a382da8cb60a)

Escribimos `rails db:seed` en la terminal y luego ejecutamos `bin/rails server`

![35](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/f5702fc3-46ae-48c4-a758-3a56968fce25)


Luego, editamos el archivo `app/models/moviegoer.rb`
```
# Edit app/models/moviegoer.rb to look like this:
class Moviegoer < ActiveRecord::Base
    def self.create_with_omniauth(auth)
        Moviegoer.create!(
        :provider => auth["provider"],
        :uid => auth["uid"],
        :name => auth["info"]["name"])
    end
end

```
Este archivo define una clase llamada Moviegoer que hereda de ActiveRecord::Base, lo que implica que se espera que interactúe con una base de datos a través de ActiveRecord. La función principal de este archivo es proporcionar un método llamado self.create_with_omniauth(auth) que se encarga de crear un nuevo registro de Moviegoer utilizando la información de autenticación (auth) proporcionada. Esta función está diseñada para ser utilizada en el contexto de autenticación mediante OmniAuth.


Ademas, se puede autenticar al usuario a través de un tercero. Usaremos la excelente gema OmniAuth que proporciona una API uniforme para muchos proveedores de SSO diferentes. Para ello, agregamos en nuestro archivo Gemfile las siguiente gemas:

```
gem 'omniauth'
gem 'omniauth-twitter'

```
Ejecutamos bundle install para incoporarlas en nuestra aplicacion localmente.


Ahora bien, la mayoría de los proveedores de autenticación requieren que registremos cualquier aplicación que utilizará su sitio para la autenticación, por lo que en este ejemplo necesitaremos crear una cuenta de desarrollador de Twitter.

![36](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/220ce362-a94e-489c-b026-49e4fbdde58e)

Insertamos en el siguiente codigo nuestra API key y API key secret que obtuvimos al registrar tu aplicación en Twitter.
```
# Replace API_KEY and API_SECRET with the values you got from Twitter
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, "API_KEY", "API_SECRET"
end
```

Agregamos el siguiente codigo en el archivo `config/routes.rb`que nos ayuda a agregar las rutas necesarias para manejar la autenticación:
```
#routes.rb
get  'auth/:provider/callback' => 'sessions#create'
get  'auth/failure' => 'sessions#failure'
get  'auth/twitter', :as => 'login'
post 'logout' => 'sessions#destroy'
```
Por ultimo, creamos un controlador de sesiones (sessions_controller.rb), el cual contiene las acciones esenciales para gestionar la autenticación.
```
class SessionsController < ApplicationController
  # login & logout actions should not require user to be logged in
  skip_before_filter :set_current_user  # check you version
  def create
    auth = request.env["omniauth.auth"]
    user =
      Moviegoer.where(provider: auth["provider"], uid: auth["uid"]) ||
      Moviegoer.create_with_omniauth(auth)
    session[:user_id] = user.id
    redirect_to movies_path
  end
  def destroy
    session.delete(:user_id)
    flash[:notice] = 'Logged out successfully.'
    redirect_to movies_path
  end
end
```


### Pregunta: Debes tener cuidado para evitar crear una vulnerabilidad de seguridad. ¿Qué sucede si un atacante malintencionado crea un envío de formulario que intenta modificar params[:moviegoer][:uid] o params[:moviegoer][:provider] (campos que solo deben modificarse mediante la lógica de autenticación) publicando campos de formulario ocultos denominados params[moviegoer][uid] y así sucesivamente?.

 
Si el atacante malintencionado logra crear un envío de formulario que intenta modificar params[:moviegoer][:uid] o params[:moviegoer][:provider] mediante la inclusión de campos ocultos como params[moviegoer][uid] y similares, podría potencialmente comprometer la seguridad de la aplicación, podría llevar a realizar cambios no autorizados en la información del usuario autenticado, lo cual resulta en el robo de identidad o en la alteración inapropiada de los datos del usuario.
 


## Asociaciones y claves foráneas

Una asociación es una relación lógica entre dos tipos de entidades de una arquitectura software. Por ejemplo, podemos añadir a RottenPotatoes las clases Review (crítica) y Moviegoer (espectador o usuario) para permitir que los usuarios escriban críticas sobre sus películas favoritas; podríamos hacer esto añadiendo una asociación de uno a muchos (one-to-many) entre las críticas y las películas (cada crítica es acerca de una película) y entre críticas y usuarios (cada crítica está escrita por exactamente un usuario).


Explica la siguientes líneas de SQL:

```
SELECT reviews.*
    FROM movies JOIN reviews ON movies.id=reviews.movie_id
    WHERE movies.id = 41;
``` 
La consulta SQL selecciona todas las columnas de la tabla "reviews" que están asociadas a la película con un id igual a 41 en la tabla "movies".

Despues de ealizar la configuracion para trabajar con asociaciones entre modelos (Movie, Moviegoer, y Review) en nuestra aplicacion ejecutamos `rails console`

![45](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/26f29d4f-5f1d-4656-8388-c0df4f4d8092)




![46](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/f3c69d63-66a1-4d1f-88de-4bd3a6928a0e)

Este código demuestra el uso de asociaciones y relaciones entre modelos en Rails para representar la relación entre películas, espectadores (usuarios) 
y revisiones.


## Asociaciones indirectas

![47](https://github.com/miguelvega/Rails-Avanzado/assets/124398378/565fb598-b144-4631-a031-b112e8f01cf7)

Volviendo a la figura siguiente, vemos asociaciones directas entre Moviegoers y Reviews, así como entre Movies y Reviews.


¿Qué indica el siguiente código SQL ?

```
SELECT movies .*
    FROM movies JOIN reviews ON movies.id = reviews.movie_id
    JOIN moviegoers ON moviegoers.id = reviews.moviegoer_id
    WHERE moviegoers.id = 1;
```

La consulta selecciona y devuelve todas las columnas de la tabla movies para aquellas películas que tienen revisiones asociadas realizadas por un moviegoer específico con un id igual a 1. En esta consulta el campo moviegoer_id de la tabla reviews sirve como puente de enlace entre las tablas movies y la tabla moviegoer para poder realizar esta consulta. Con lo cual si hay dos tablas que no se conectan pero deseas hacer una consultas que involucren campos de dichas tablas, entonces una solucion seria usar una tabla intermediaria de tal modo que tenga campos que se relacionen con dichas tablas. 


Se ha  añadido `has_many :reviews` a la clase `Movie`.  El método `has_many` utiliza la metaprogramación para definir el nuevo método de `instancia reviews=` que usamos en el código siguiente.     

```
# it would be nice if we could do this:
inception = Movie.where(:title => 'Inception')
alice,bob = Moviegoer.find(alice_id, bob_id)
# alice likes Inception, bob less so
alice_review = Review.new(:potatoes => 5)
bob_review   = Review.new(:potatoes => 3)
# a movie has many reviews:
inception.reviews = [alice_review, bob_review]
# a moviegoer has many reviews:
alice.reviews << alice_review
bob.reviews << bob_review
# can we find out who wrote each review?
inception.reviews.map { |r| r.moviegoer.name } # => ['alice','bob']
```
