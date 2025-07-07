package main

import (
	"net/http"

	"github.com/justinas/alice"

	"snippets_web/ui"
)

// BUG:
// redirectToHTTPS es una función middleware que redirige todas las solicitudes HTTP a HTTPS.
func (app *application) redirectToHTTPS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if app.config.env == "development" {
			next.ServeHTTP(w, r)
		}

		// Solo redirigimos si la conexión no es ya HTTPS
		if r.Header.Get("X-Forwarded-Proto") != "https" && r.URL.Scheme != "https" {
			target := "https://" + r.Host + r.URL.Path
			if len(r.URL.RawQuery) > 0 {
				target += "?" + r.URL.RawQuery
			}
			http.Redirect(w, r, target, http.StatusPermanentRedirect)
			// return // Importante: detiene el procesamiento de la solicitud después de la redirección
		}

		next.ServeHTTP(w, r)
	})
}

func (app *application) routes() http.Handler {
	mux := http.NewServeMux()

	if app.config.embedded {
		// Use the http.FileServerFS() function to create a HTTP handler which serves the embedded files in ui.Files. It's important to note that our static files are contained in the "static" folder of the ui.Files embedded filesystem. So, for example, our CSS stylesheet is located at "static/css/main.css". This means that we no longer need to strip the prefix from the request URL -- any requests that start with /static/ can just be passed directly to the file server and the corresponding static file will be served (so long as it exists).
		mux.Handle("GET /static/", http.FileServerFS(ui.Files))
	} else {
		fileServer := http.FileServer(http.Dir("./ui/static/"))
		mux.Handle("GET /static/", http.StripPrefix("/static", fileServer))
	}
	// Add a new GET /ping route.
	mux.HandleFunc("GET /ping", ping)

	dynamic := alice.New(
		// app.redirectToHTTPS,
		app.sessionManager.LoadAndSave,
		app.noSurf,
		app.authenticate,
		app.commonHeaders,
	)

	mux.Handle("GET /{$}", dynamic.ThenFunc(app.home))
	mux.Handle("GET /about", dynamic.ThenFunc(app.about))
	mux.Handle("GET /snippet/view/{id}", dynamic.ThenFunc(app.snippetView))
	mux.Handle("GET /user/signup", dynamic.ThenFunc(app.userSignup))
	mux.Handle("POST /user/signup", dynamic.ThenFunc(app.userSignupPost))
	mux.Handle("GET /user/login", dynamic.ThenFunc(app.userLogin))
	mux.Handle("POST /user/login", dynamic.ThenFunc(app.userLoginPost))
	mux.Handle("GET /foobarerr", dynamic.ThenFunc(app.foobarerr))
	// Protected (authenticated-only) application routes, using a new "protected" middleware chain which includes the requireAuthentication middleware.
	protected := dynamic.Append(app.requireAuthentication)

	mux.Handle("GET /snippet/create", protected.ThenFunc(app.snippetCreate))
	mux.Handle("POST /snippet/create", protected.ThenFunc(app.snippetCreatePost))
	mux.Handle("GET /account/view", protected.ThenFunc(app.accountView))
	mux.Handle("GET /account/password/update", protected.ThenFunc(app.accountPasswordUpdate))
	mux.Handle("POST /account/password/update", protected.ThenFunc(app.accountPasswordUpdatePost))
	mux.Handle("POST /user/logout", protected.ThenFunc(app.userLogoutPost))

	// standard := alice.New(app.recoverPanic, app.logRequest, app.commonHeaders)
	standard := alice.New(app.recoverPanic, app.logRequest)

	return standard.Then(mux)
}
