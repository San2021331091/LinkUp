package main

import (
	"encoding/json"
	"errors"
	"html/template"
	"io"
	"log"
	"net/http"
)

const supabaseURL = "your supabase url"
const supabaseKey = "your supabase anon key"

// ================== STRUCTS ==================

// Video struct
type Video struct {
	ArtistSongName string `json:"artist_song_name"`
	ThumbnailURL   string `json:"thumbnail_url"`
}

// Videos slice with custom unmarshal
type Videos []Video

func (v *Videos) UnmarshalJSON(data []byte) error {
	if data[0] == '{' {
		var single Video
		if err := json.Unmarshal(data, &single); err != nil {
			return err
		}
		*v = []Video{single}
		return nil
	}
	return json.Unmarshal(data, (*[]Video)(v))
}

// User struct
type User struct {
	UID            string   `json:"uid"`
	Name           string   `json:"name"`
	Email          string   `json:"email"`
	Image          string   `json:"image"`
	Youtube        string   `json:"youtube"`
	Facebook       string   `json:"facebook"`
	Twitter        string   `json:"twitter"`
	Instagram      string   `json:"instagram"`
	CreatedAt      string   `json:"created_at"`
	UpdatedAt      string   `json:"updated_at"`
	FollowersCount int      `json:"followers_count"`
	Following      []string `json:"following"`
}

// Users slice with custom unmarshal
type Users []User

func (u *Users) UnmarshalJSON(data []byte) error {
	if data[0] == '{' {
		var single User
		if err := json.Unmarshal(data, &single); err != nil {
			return err
		}
		*u = []User{single}
		return nil
	}
	return json.Unmarshal(data, (*[]User)(u))
}

// Earning struct
type Earning struct {
	ID              int     `json:"id"`
	VideoID         string  `json:"video_id"`
	UserID          string  `json:"user_id"`
	LikesEarning    float64 `json:"likes_earning"`
	CommentsEarning float64 `json:"comments_earning"`
	TotalEarning    float64 `json:"total_earning"`
	UpdatedAt       string  `json:"updated_at"`

	Videos Videos `json:"videos"`
	Users  Users  `json:"users"`
}

// ================== FETCH FUNCTION ==================
func fetchUserEarnings(userID string) ([]Earning, error) {
	url := supabaseURL + `/rest/v1/member_earnings?user_id=eq.` + userID +
		`&select=*,videos!inner(artist_song_name,thumbnail_url),users!inner(name,email,image,youtube,facebook,twitter,instagram,created_at,updated_at,followers_count,following)&order=updated_at.desc`

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("apikey", supabaseKey)
	req.Header.Set("Authorization", "Bearer "+supabaseKey)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)

	if resp.StatusCode != 200 {
		return nil, errors.New(string(body))
	}

	var data []Earning
	if err := json.Unmarshal(body, &data); err != nil {
		log.Println("Decode error:", err)
		log.Println("Raw response:", string(body))
		return nil, err
	}

	return data, nil
}

// ================== HANDLER ==================
func userEarningHandler(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Query().Get("user_id")
	if userID == "" {
		http.Error(w, "Missing user_id (?user_id=...)", http.StatusBadRequest)
		return
	}

	data, err := fetchUserEarnings(userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	tmpl := template.Must(template.ParseFiles("templates/user_earning.html"))
	tmpl.Execute(w, data)
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	w.Write([]byte("🚀 Go server is running!"))
}

// ================== MAIN ==================
func main() {
	http.HandleFunc("/", rootHandler)
	http.HandleFunc("/user_earning", userEarningHandler)
	log.Println("🚀 Server running at port:8500")
	log.Fatal(http.ListenAndServe(":8500", nil))
}
