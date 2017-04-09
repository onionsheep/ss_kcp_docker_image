package main

import (
	"fmt"
	"io/ioutil"
	"os"

	"github.com/bitly/go-simplejson"
)

func main() {
	parseArukasJSON()
}

func parseArukasJSON() {
	var jsonarg string
	var jsonbytes []byte
	if len(os.Args) > 1 {
		jsonarg = os.Args[1]
	} else {
		bytes, err := ioutil.ReadAll(os.Stdin)
		if err != nil {
			panic("read Stdin error")
		}
		jsonbytes = bytes
	}
	fmt.Println(jsonarg)
	if jsonbytes == nil && jsonarg != "" {
		jsonbytes = []byte(jsonarg)
	}
	js, err := simplejson.NewJson(jsonbytes)
	if err != nil {
		panic("json format error")
	}
	arr, err := js.Get("data").Array()
	if err != nil {
		fmt.Println("decode error: get int failed!")
		return
	}

	// fmt.Println(arr)
	for ci, container := range arr {
		fmt.Println("container index:", ci)
		c := container.(map[string]interface{})
		attributes := c["attributes"].(map[string]interface{})
		imageName := attributes["image_name"]
		fmt.Println("image_name:", imageName)
		if imageName == "onionsheep/ss_kcp:latest" {
			portMappings := attributes["port_mappings"]
			pmsa := portMappings.([]interface{})
			pms := pmsa[0].([]interface{})
			for pmi, pm := range pms {
				pmmap := pm.(map[string]interface{})
				fmt.Println(pmmap["container_port"])
				if pmmap["container_port"] == 4000 {
					fmt.Println(pmi, pm)
				}
			}
		}

	}
}
