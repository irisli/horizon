package main

import (
	"database/sql"
	"log"
	"os"
	"strconv"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	"github.com/stellar/horizon/db/schema"
)

var dbCmd = &cobra.Command{
	Use:   "db [command]",
	Short: "commands to manage horizon's postgres db",
}

var dbInitCmd = &cobra.Command{
	Use:   "init",
	Short: "install schema",
	Long:  "init initializes the postgres database used by horizon.",
	Run: func(cmd *cobra.Command, args []string) {
		db, err := sql.Open("postgres", viper.GetString("db-url"))
		if err != nil {
			log.Fatal(err)
		}

		err = schema.Init(db)
		if err != nil {
			log.Fatal(err)
		}
	},
}

var dbMigrateCmd = &cobra.Command{
	Use:   "migrate [up|down|redo] [COUNT]",
	Short: "migrate schema",
	Long:  "performs a schema migration command",
	Run: func(cmd *cobra.Command, args []string) {

		// Allow invokations with 1 or 2 args.  All other args counts are erroneous.
		if len(args) < 1 || len(args) > 2 {
			cmd.Usage()
			os.Exit(1)
		}

		dir := schema.MigrateDir(args[0])
		count := 0

		// If a second arg is present, parse it to an int and use it as the count
		// argument to the migration call.
		if len(args) == 2 {
			var err error
			count, err = strconv.Atoi(args[1])
			if err != nil {
				log.Println(err)
				cmd.Usage()
				os.Exit(1)
			}
		}

		db, err := sql.Open("postgres", viper.GetString("db-url"))
		if err != nil {
			log.Fatal(err)
		}

		_, err = schema.Migrate(db, dir, count)
		if err != nil {
			log.Fatal(err)
		}
	},
}

func init() {
	dbCmd.AddCommand(dbInitCmd)
	dbCmd.AddCommand(dbMigrateCmd)
}
