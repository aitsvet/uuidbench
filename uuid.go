package main

import (
	"log"
	"os"
	"strconv"

	"github.com/go-redis/redis"
	"github.com/google/uuid"
	"github.com/syndtr/goleveldb/leveldb"
)

func main() {
	daily, err := strconv.ParseUint(os.Args[1], 10, 64)
	if err != nil {
		log.Fatal("Usage: ./" + os.Args[0] + " <number of uuids per day>")
	}
	redis_server := os.Getenv("REDIS_SERVER")
	if redis_server == "" {
		db, err := leveldb.OpenFile("data", nil)
		if err != nil {
			log.Fatal(err)
		}
		defer db.Close()
		for ; daily > 0; daily-- {
			id := uuid.New().String()
			err = db.Put([]byte(id), nil, nil)
			if err != nil {
				log.Fatal(err)
			}
		}
	} else {
		client := redis.NewClient(&redis.Options{
			Addr:     redis_server,
			Password: "",
			DB:       0,
		})
		_, err := client.Ping().Result()
		if err != nil {
			log.Fatal(err)
		}
		defer client.Close()
		for ; daily > 0; daily-- {
			id := uuid.New().String()
			err = client.Set(id, nil, 0).Err()
			if err != nil {
				log.Fatal(err)
			}
		}
	}
}
