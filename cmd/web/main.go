package main

import (
	"context"
	"crypto/tls"
	"database/sql"
	"flag"
	"fmt"
	"html/template"
	"log/slog"
	"net/http"
	"os"
	"time"

	"github.com/alexedwards/scs/postgresstore"
	"github.com/alexedwards/scs/v2"
	"github.com/go-playground/form/v4"
	_ "github.com/lib/pq"

	"snippets_web/internal/models"
)

type config struct {
	port     int
	env      string
	debug    bool
	embedded bool
	db       struct {
		dsn          string
		maxOpenConns int
		maxIdleConns int
		maxIdleTime  time.Duration
	}
	// limiter struct {
	// 	enabled bool
	// 	rps     float64
	// 	burst   int
	// }
	// smtp struct {
	// 	host     string
	// 	port     int
	// 	username string
	// 	password string
	// 	sender   string
	// }
	// cors struct {
	// 	trustedOrigins []string
	// }
}

type application struct {
	// snippets       *models.SnippetModel
	// users          *models.UserModel
	config         config
	logger         *slog.Logger
	snippets       models.SnippetModelInterface
	users          models.UserModelInterface
	templateCache  map[string]*template.Template
	formDecoder    *form.Decoder
	sessionManager *scs.SessionManager
	// models data.Models
	// mailer mailer.Mailer
	// wg     sync.WaitGroup
}

func openDB(cfg config) (*sql.DB, error) {
	db, err := sql.Open("postgres", cfg.db.dsn)
	// fmt.Println("cfg.db.dsn --> ", cfg.db.dsn)
	if err != nil {
		return nil, err
	}

	db.SetMaxOpenConns(cfg.db.maxOpenConns)
	db.SetMaxIdleConns(cfg.db.maxIdleConns)
	db.SetConnMaxIdleTime(cfg.db.maxIdleTime)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	err = db.PingContext(ctx)
	if err != nil {
		db.Close()
		return nil, err
	}

	return db, nil
}

func main() {
	var cfg config

	flag.IntVar(&cfg.port, "port", 22333, "HTTP network address")
	flag.StringVar(&cfg.env, "env", "development", "Environment (development|staging|production)")

	// flag.StringVar(&cfg.db.dsn, "db-dsn", "", "PostgreSQL DSN")
	flag.StringVar(&cfg.db.dsn, "db-dsn", os.Getenv("SNIPPETS_WEB_DB_DSN"), "PostgreSQL DSN")

	flag.IntVar(&cfg.db.maxOpenConns, "db-max-open-conns", 25, "PostgreSQL max open connections")
	flag.IntVar(&cfg.db.maxIdleConns, "db-max-idle-conns", 25, "PostgreSQL max idle connections")
	flag.DurationVar(
		&cfg.db.maxIdleTime,
		"db-max-idle-time",
		15*time.Minute,
		"PostgreSQL max connection idle time",
	)

	// TODO:
	// WARNING:
	// https://github.com/gravityblast/fresh/blob/master/runner/settings.go
	debug := flag.Bool("debug", true, "Enable debug mode")
	cfg.debug = *debug
	embedded := flag.Bool("embedded", false, "Use embedded files for static assets")
	cfg.embedded = *embedded

	flag.Parse()

	logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
	// logger.Info("starting server", "addr", cfg.port)

	db, err := openDB(cfg)
	if err != nil {
		logger.Error(err.Error())
		os.Exit(1)
	}
	defer db.Close()
	logger.Info("database connection pool established")
	// Initialize a new template cache...
	templateCache, err := newTemplateCache(cfg.embedded)
	if err != nil {
		logger.Error(err.Error())
		os.Exit(1)
	}

	formDecoder := form.NewDecoder()

	sessionManager := scs.New()
	sessionManager.Store = postgresstore.New(db)
	sessionManager.Lifetime = 12 * time.Hour
	// Make sure that the Secure attribute is set on our session cookies. Setting this means that the cookie will only be sent by a user's web browser when a HTTPS connection is being used (and won't be sent over an unsecure HTTP connection).
	sessionManager.Cookie.Secure = true

	app := &application{
		// debug:          *debug,
		config:         cfg,
		logger:         logger,
		snippets:       &models.SnippetModel{DB: db},
		users:          &models.UserModel{DB: db},
		templateCache:  templateCache,
		formDecoder:    formDecoder,
		sessionManager: sessionManager,
	}

	// Initialize a tls.Config struct to hold the non-default TLS settings we want the server to use. In this case the only thing that we're changing is the curve preferences value, so that only elliptic curves with assembly implementations are used.
	tlsConfig := &tls.Config{
		CurvePreferences: []tls.CurveID{tls.X25519, tls.CurveP256},
	}

	// Initialize a new http.Server struct. We set the Addr and Handler fields so that the server uses the same network address and routes as before.
	// Create a *log.Logger from our structured logger handler, which writes log entries at Error level, and assign it to the ErrorLog field. If you would prefer to log the server errors at Warn level instead, you could pass slog.LevelWarn as the final parameter.
	srv := &http.Server{
		Addr:         ":" + fmt.Sprint(cfg.port),
		Handler:      app.routes(),
		ErrorLog:     slog.NewLogLogger(logger.Handler(), slog.LevelError),
		TLSConfig:    tlsConfig,
		IdleTimeout:  time.Minute,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
	}

	logger.Info("starting server", "addr", srv.Addr)
	// Call the new app.routes() method to get the servemux containing our routes, and pass that to http.ListenAndServe().
	// err = http.ListenAndServe(":"+fmt.Sprint(cfg.port), app.routes())
	err = srv.ListenAndServe()
	// Use the ListenAndServeTLS() method to start the HTTPS server. We pass in the paths to the TLS certificate and corresponding private key as the two parameters.
	// err = srv.ListenAndServeTLS("./tls/cert.pem", "./tls/key.pem")
	logger.Error(err.Error())
	os.Exit(1)
}

// /home/lenovo/Downloads/letsgo/lets-go-professional-package231024/html/09.03-generating-a-self-signed-tls-certificate.html
// go run /home/lenovo/coding/go/src/crypto/tls/generate_cert.go --rsa-bits=2048 --host=localhost
// https://localhost:22333/
