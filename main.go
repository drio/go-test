// This is a little testing app server. We can use it to test the main proxy
// server to make sure it is proxing request properly
package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
)

func root(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	fmt.Fprintf(w, `<!DOCTYPE html>
<html lang="en"> <meta charset=utf-8>
<style>
:root {
  font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
    Segoe UI, Roboto, Helvetica Neue, Arial, Noto Sans, sans-serif,
    "Apple Color Emoji", "Segoe UI Emoji", Segoe UI Symbol, "Noto Color Emoji";
  margin: 0 auto;
  width: 75%%;
  background: white;
  padding: 10px;
}

.container {
  display: flex;
  flex-direction: column;
}

small {
  font-size: .7rem;
  color: grey;
}

.button {
  width: fit-content;
  border: solid 2px steelblue;
  padding: 5px;
  border-radius: 5px;
}

.hand {
  font-size: 1rem;
}


</style>

<div class="container">
<p>
	Welcome to this amazing app <span class="hand">🤘</span>! <br/><br/>
	user-agent:<br/> <small>%s</small> <br/>
	userid: <small>%s</small> <br/>

  <p class="button"><a href="/logout">Logout</a></p>
 
</p>
</div>
`, r.Header["User-Agent"], r.Header["Sb-Uid"])
}

func headers(w http.ResponseWriter, req *http.Request) {
	for name, headers := range req.Header {
		for _, h := range headers {
			fmt.Fprintf(w, "%v: %v\n", name, h)
		}
	}
}

func cookies(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintf(w, "Printing cookies..\n")
	for _, c := range req.Cookies() {
		fmt.Fprintf(w, "%s: %s\n", c.Name, c.Value)
	}
	fmt.Fprintf(w, "\n")
}

func main() {
	port := flag.String("port", "9001", "Port to listen to")
	flag.Parse()

	http.HandleFunc("/", root)
	http.HandleFunc("/headers", headers)
	http.HandleFunc("/cookies", cookies)
	fmt.Printf("Listening on port %s\n", *port)
	err := http.ListenAndServe(fmt.Sprintf("127.0.0.1:%s", *port), nil)
	if err != nil {
		log.Fatal(err)
	}
}
