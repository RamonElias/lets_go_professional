package main

import (
	"bytes"
	"crypto/rand"
	"encoding/base64"
	"errors"
	"fmt"
	"net/http"
	"runtime/debug"
	"time"

	"github.com/go-playground/form/v4"
	"github.com/justinas/nosurf"
)

//	func (app *application) isAuthenticated(r *http.Request) bool {
//		return app.sessionManager.Exists(r.Context(), "authenticatedUserID")
//	}
func (app *application) isAuthenticated(r *http.Request) bool {
	isAuthenticated, ok := r.Context().Value(isAuthenticatedContextKey).(bool)
	if !ok {
		return false
	}

	return isAuthenticated
}

func (app *application) newTemplateData(r *http.Request) templateData {
	csrf_token := nosurf.Token(r)
	fmt.Println("csrf_token --> ", csrf_token)

	return templateData{
		// CSRFToken:       nosurf.Token(r),
		// Nonce:           app.generateNonce(),
		CurrentYear:     time.Now().Year(),
		Flash:           app.sessionManager.PopString(r.Context(), "flash"),
		IsAuthenticated: app.isAuthenticated(r),
		CSRFToken:       csrf_token,
		Uri:             r.URL.RequestURI(),
		Nonce:           app.sessionManager.PopString(r.Context(), "nonce"),
	}
}

func (app *application) render(
	w http.ResponseWriter,
	r *http.Request,
	status int,
	page string,
	data templateData,
) {
	ts, ok := app.templateCache[page]
	if !ok {
		err := fmt.Errorf("the template %s does not exist", page)
		app.serverError(w, r, err)
		return
	}

	// Initialize a new buffer.
	buf := new(bytes.Buffer)

	// Write the template to the buffer, instead of straight to the
	// http.ResponseWriter. If there's an error, call our serverError() helper
	// and then return.
	err := ts.ExecuteTemplate(buf, "base", data)
	if err != nil {
		app.serverError(w, r, err)
		return
	}

	// /home/lenovo/Downloads/letsgo/lets-go-professional-package231024/html/09.02-the-server-error-log.html
	// Deliberate error: set a Content-Length header with an invalid (non-integer) value.
	// w.Header().Set("Content-Length", "this isn't an integer!")

	// If the template is written to the buffer without any errors, we are safe
	// to go ahead and write the HTTP status code to http.ResponseWriter.
	w.WriteHeader(status)

	// Write the contents of the buffer to the http.ResponseWriter. Note: this
	// is another time where we pass our http.ResponseWriter to a function that
	// takes an io.Writer.
	buf.WriteTo(w)
}

// Create a new decodePostForm() helper method. The second parameter here, dst, is the target destination that we want to decode the form data into.
// /home/lenovo/Downloads/letsgo/lets-go-professional-package231024/html/07.06-automatic-form-parsing.html
func (app *application) decodePostForm(r *http.Request, dst any) error {
	err := r.ParseForm()
	if err != nil {
		return err
	}

	// Call Decode() on our decoder instance, passing the target destination as the first parameter.
	err = app.formDecoder.Decode(dst, r.PostForm)
	if err != nil {
		// If we try to use an invalid target destination, the Decode() method will return an error with the type *form.InvalidDecoderError.We use errors.As() to check for this and raise a panic rather than returning the error.
		var invalidDecoderError *form.InvalidDecoderError

		if errors.As(err, &invalidDecoderError) {
			panic(err)
		}

		// For all other errors, we return them as normal.
		return err
	}

	return nil
}

// The serverError helper writes a log entry at Error level (including the request
// method and URI as attributes), then sends a generic 500 Internal Server Error
// response to the user.
func (app *application) serverError(w http.ResponseWriter, r *http.Request, err error) {
	var (
		method = r.Method
		uri    = r.URL.RequestURI()
		// Use debug.Stack() to get the stack trace. This returns a byte slice, which we need to convert to a string so that it's readable in the log entry.
		trace = string(debug.Stack())
	)

	// app.logger.Error(err.Error(), "method", method, "uri", uri)
	app.logger.Error(err.Error(), "method", method, "uri", uri, "trace", trace)

	if app.config.debug {
		body := fmt.Sprintf("%s\n%s", err, trace)
		http.Error(w, body, http.StatusInternalServerError)
		return
	}

	http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
}

// The clientError helper sends a specific status code and corresponding description to the user. We'll use this later in the book to send responses like 400 "Bad Request" when there's a problem with the request that the user sent.
func (app *application) clientError(w http.ResponseWriter, status int) {
	http.Error(w, http.StatusText(status), status)
}

// func (app *application) generateNonce() (string, error) {
func (app *application) generateNonce() string {
	// Genera 16 bytes aleatorios (puedes ajustar el tamaño)
	bytes := make([]byte, 16)
	if _, err := rand.Read(bytes); err != nil {
		// return "", err
		panic(err)
	}
	// Codifica en Base64 (sin "==" al final)
	nonce := base64.StdEncoding.EncodeToString(bytes)
	// fmt.Println("nonce --> ", nonce)
	// return base64.StdEncoding.EncodeToString(bytes), nil
	return nonce[:len(nonce)-2] // Elimina los últimos dos caracteres "==" si es necesario
}
