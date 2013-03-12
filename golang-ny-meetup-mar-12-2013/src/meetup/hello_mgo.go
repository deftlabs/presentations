
package main

import (
	"fmt"
	"labix.org/v2/mgo"
	"labix.org/v2/mgo/bson"
)

type Dog struct {
	Name string
	Drools bool
	AlwaysHungry bool
	HoursSleptPerDay int
}

func main() {

	// Create a mgo session
	session, err := mgo.Dial("mongodb://127.0.0.1/test")
	if err != nil {
		panic(err)
	}

	// Close the session when the function ends
	defer session.Close()

	fmt.Println("Yay! We have a mgo session")

	// Run a command
	var serverStatus = &bson.M{}
	if err := session.Run("serverStatus", serverStatus); err != nil {
		panic(err)
	} else {
		//fmt.Println(*serverStatus)
	}

	// Run a command with an argument
	var startupWarnings = &bson.M{}
	if err := session.Run(bson.D{{"getLog", "startupWarnings"}}, startupWarnings); err != nil {
		panic(err)
	} else {
		//fmt.Println(*startupWarnings)
	}

	// Insert a document
	var testDoc = bson.M{}
	testDoc["name"] = "Ryan Nitz"
	var testId = bson.NewObjectId()
	testDoc["testId"] = testId
	testDoc["slice"] = []string { "one", "two", "three", "four" }
	session.DB("test").C("golangny").Insert(&testDoc)

	// Insert a document using marshalling
	session.DB("test").C("golangny").Insert(&Dog{Name: "Loo", Drools: false, AlwaysHungry: true, HoursSleptPerDay: 18})

	// Read a single document
	var testResultDoc = bson.M{}
	if err := session.DB("test").C("golangny").Find(bson.M{"testId": testId}).One(&testResultDoc); err != nil {
		if err == mgo.ErrNotFound {
			fmt.Println("The document was not found")
		} else {
			panic(err)
		}
	} else {
		if testResultDoc != nil {
			fmt.Println(testResultDoc)
		}
	}

	// Read multiple documents
	iter := session.DB("test").C("golangny").Find(nil).Iter()
	var result = &bson.M{}
	for iter.Next(&result) {
    	fmt.Printf("Result: %v\n", *result)
	}
	if iter.Err() != nil {
    	panic(iter.Err())
	}

}

