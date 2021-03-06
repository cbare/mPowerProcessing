library(crayon)

# when set to 'true' the test suite will generate unit test data that becomes part of the code base
# Note that since data generators have to be run in a certain order, we have named the tests 
# (under test/testthat) to ensure execution in that order.
createTestData<-function() {FALSE}

## HELPER FUNCTIONS FOR PERMUTATIONS
## generateUuids, permuteMe

generateUuids <- function(n){
  require(uuid)
  res <- rep(NA, n)
  for(i in 1:n){
    res[i] <- UUIDgenerate(FALSE)
  }
  return(res)
}

## CREATES RANDOM UUIDS FOR APPROPRIATE COLUMNS
## SHUFFLES ALL COLUMNS
permuteMe <- function(dat){
  uuidFields <- c("recordId", "healthCode")
  for(ii in uuidFields){
    dat[[ii]] <- generateUuids(nrow(dat))
  }
  for(ii in names(dat)){
    dat[[ii]] <- dat[[ii]][sample(1:nrow(dat), size=nrow(dat))]
  }
  return(dat)
}

getIdFromSql<-function(sql) {
	sql<-tolower(sql)
	start<-pracma::strfind(sql, "syn")
	end<-pracma::strfind(sql, " where")
	if (is.null(end)) end<-1+nchar(sql)
	substr(sql, start, end-1)
}

# prepend the column called 'healthCode' with the given prefix
prependHealthCodes<-function(df, prefix) {
	if (!is.null(df$`health-code`)) {
		df$`health-code` <- prefix  %+% df$`health-code`
	}
	df
}

# mocks attachment files using the files in the given 'folder'
# if 'readJson' is true, reads/converts json content of files
# returns two lists:
# The first maps file handles to file paths.
# The second maps file paths to file content.
mockFileAttachments<-function(folder, readJson=F) {
	# make a list of the mock attachment files, found in the given folder
	mockFiles <- list.files(folder, full.names = TRUE)
	# create fake file handle ID labels on 'mockFiles'
	names(mockFiles)<-sample(100000:999999, size=length(mockFiles), replace=F)
	# read in the content
	if (readJson) {
		fileContent <- sapply(mockFiles, read_json_from_file)
	} else {
		fileContent <- sapply(mockFiles, function(x){paste(readLines(x,warn=F), collapse="\n")})
	}
	names(fileContent)<-mockFiles # maps file path to file content
	list(mockFiles=mockFiles, fileContent=fileContent)
}

# to generate the column definitions:
# schema<-synGet(id)
# for (c in schema@columns@content) message("TableColumn(name=\"", c@name, "\", columnType=\"", c@columnType, "\"),")
#
demographicSurveySchema<-function(projectId) {
	TableSchema("Demographics Survey", projectId, list(
					TableColumn(name="recordId", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="healthCode", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="createdOn", columnType="DATE"),
					TableColumn(name="appVersion", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="phoneInfo", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="age", columnType="INTEGER"),
					TableColumn(name="are-caretaker", columnType="BOOLEAN"),
					TableColumn(name="deep-brain-stimulation", columnType="BOOLEAN"),
					TableColumn(name="diagnosis-year", columnType="INTEGER"),
					TableColumn(name="education", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="employment", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="gender", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="health-history", columnType="STRING", maximumSize=as.integer(997)),
					TableColumn(name="healthcare-provider", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="home-usage", columnType="BOOLEAN"),
					TableColumn(name="last-smoked", columnType="INTEGER"),
					TableColumn(name="maritalStatus", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="medical-usage", columnType="BOOLEAN"),
					TableColumn(name="medical-usage-yesterday", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="medication-start-year", columnType="INTEGER"),
					TableColumn(name="onset-year", columnType="INTEGER"),
					TableColumn(name="packs-per-day", columnType="INTEGER"),
					TableColumn(name="past-participation", columnType="BOOLEAN"),
					TableColumn(name="phone-usage", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="professional-diagnosis", columnType="BOOLEAN"),
					TableColumn(name="race", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="smartphone", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="smoked", columnType="BOOLEAN"),
					TableColumn(name="surgery", columnType="BOOLEAN"),
					TableColumn(name="video-usage", columnType="BOOLEAN"),
					TableColumn(name="years-smoking", columnType="INTEGER")
			))
}

updrsSurveySchema<-function(projectId) {
	TableSchema("UPDRS Survey", projectId, list(
					TableColumn(name="recordId", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="healthCode", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="createdOn", columnType="DATE"),
					TableColumn(name="appVersion", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="phoneInfo", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="EQ-5D1", columnType="INTEGER"),
					TableColumn(name="GELTQ-1a", columnType="INTEGER"),
					TableColumn(name="GELTQ-1b", columnType="INTEGER"),
					TableColumn(name="GELTQ-1c", columnType="INTEGER"),
					TableColumn(name="GELTQ-2", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="MDS-UPDRS1.3", columnType="INTEGER"),
					TableColumn(name="MDS-UPDRS1.4", columnType="INTEGER"),
					TableColumn(name="MDS-UPDRS1.5", columnType="INTEGER"),
					TableColumn(name="MDS-UPDRS1.7", columnType="INTEGER"),
					TableColumn(name="MDS-UPDRS1.8", columnType="INTEGER"),
					TableColumn(name="MDS-UPDRS2.1", columnType="INTEGER"),
					TableColumn(name="MDS-UPDRS2.4", columnType="INTEGER"),
					TableColumn(name="MDS-UPDRS2.5", columnType="INTEGER"),
					TableColumn(name="MDS-UPDRS2.6", columnType="INTEGER"),
					TableColumn(name="MDS-UPDRS2.7", columnType="INTEGER"),
					TableColumn(name="MDS-UPDRS2.8", columnType="INTEGER"),
					TableColumn(name="MDS-UPDRS2.9", columnType="INTEGER"),
					TableColumn(name="MDS-UPDRS2.10", columnType="INTEGER"),
					TableColumn(name="MDS-UPDRS2.12", columnType="INTEGER"),
					TableColumn(name="MDS-UPDRS2.13", columnType="INTEGER"),
					TableColumn(name="MDS-UPDRS1.1", columnType="INTEGER")
			))
}

pdq8SurveySchema<-function(projectId) {
	TableSchema("PDQ8 Survey", projectId, list(
					TableColumn(name="recordId", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="healthCode", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="createdOn", columnType="DATE"),
					TableColumn(name="appVersion", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="phoneInfo", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="PDQ8-1", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="PDQ8-2", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="PDQ8-3", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="PDQ8-4", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="PDQ8-5", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="PDQ8-6", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="PDQ8-7", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="PDQ8-8", columnType="STRING", maximumSize=as.integer(200))
			))
}

memoryActivitySchema<-function(projectId) {
	TableSchema("Memory Activity", projectId, list(
					TableColumn(name="recordId", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="healthCode", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="createdOn", columnType="DATE"),
					TableColumn(name="appVersion", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="phoneInfo", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="MemoryGameResults.json.MemoryGameOverallScore", columnType="INTEGER"),
					TableColumn(name="MemoryGameResults.json.MemoryGameNumberOfGames", columnType="INTEGER"),
					TableColumn(name="MemoryGameResults.json.MemoryGameNumberOfFailures", columnType="INTEGER"),
					TableColumn(name="MemoryGameResults.json.startDate", columnType="DATE"),
					TableColumn(name="MemoryGameResults.json.endDate", columnType="DATE"),
					TableColumn(name="MemoryGameResults.json.MemoryGameGameRecords", columnType="FILEHANDLEID"),
					TableColumn(name="medTimepoint", columnType="STRING", maximumSize=as.integer(200))
			))
}

tappingActivitySchema<-function(projectId) {
	TableSchema("Tapping Activity", projectId, list(
					TableColumn(name="recordId", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="healthCode", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="createdOn", columnType="DATE"),
					TableColumn(name="appVersion", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="phoneInfo", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="accel_tapping.json.items", columnType="FILEHANDLEID"),
					TableColumn(name="tapping_results.json.ButtonRectLeft", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="tapping_results.json.ButtonRectRight", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="tapping_results.json.endDate", columnType="DATE"),
					TableColumn(name="tapping_results.json.startDate", columnType="DATE"),
					TableColumn(name="tapping_results.json.TappingSamples", columnType="FILEHANDLEID"),
					TableColumn(name="tapping_results.json.TappingViewSize", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="medTimepoint", columnType="STRING", maximumSize=as.integer(200))
			))
}

tappingLeftrightActivitySchema<-function(projectId) {
  TableSchema("Tapping Activity - Left and Right", projectId, list(
    TableColumn(name="recordId", columnType="STRING", maximumSize=as.integer(200)),
    TableColumn(name="healthCode", columnType="STRING", maximumSize=as.integer(200)),
    TableColumn(name="createdOn", columnType="DATE"),
    TableColumn(name="appVersion", columnType="STRING", maximumSize=as.integer(200)),
    TableColumn(name="phoneInfo", columnType="STRING", maximumSize=as.integer(200)),
    TableColumn(name="accel_tapping_right.json.items", columnType="FILEHANDLEID"),
    TableColumn(name="accel_tapping_left.json.items", columnType="FILEHANDLEID"),
    TableColumn(name="tapping_right.json.ButtonRectLeft", columnType="STRING", maximumSize=as.integer(200)),
    TableColumn(name="tapping_left.json.ButtonRectLeft", columnType="STRING", maximumSize=as.integer(200)),
    TableColumn(name="tapping_right.json.ButtonRectRight", columnType="STRING", maximumSize=as.integer(200)),
    TableColumn(name="tapping_left.json.ButtonRectRight", columnType="STRING", maximumSize=as.integer(200)),
    TableColumn(name="tapping_right.json.endDate", columnType="DATE"),
    TableColumn(name="tapping_left.json.endDate", columnType="DATE"),
    TableColumn(name="tapping_right.json.startDate", columnType="DATE"),
    TableColumn(name="tapping_left.json.startDate", columnType="DATE"),
    TableColumn(name="tapping_right.json.TappingSamples", columnType="FILEHANDLEID"),
    TableColumn(name="tapping_left.json.TappingSamples", columnType="FILEHANDLEID"),
    TableColumn(name="tapping_right.json.TappingViewSize", columnType="STRING", maximumSize=as.integer(200)),
    TableColumn(name="tapping_left.json.TappingViewSize", columnType="STRING", maximumSize=as.integer(200)),
    TableColumn(name="medTimepoint", columnType="STRING", maximumSize=as.integer(200)),
    TableColumn(name="dataGroups", columnType="STRING", maximumSize=as.integer(200))
  ))
}

voiceActivitySchema<-function(projectId) {
	TableSchema("Voice Activity", projectId, list(
					TableColumn(name="recordId", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="healthCode", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="createdOn", columnType="DATE"),
					TableColumn(name="appVersion", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="phoneInfo", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="audio_audio.m4a", columnType="FILEHANDLEID"),
					TableColumn(name="audio_countdown.m4a", columnType="FILEHANDLEID"),
					TableColumn(name="medTimepoint", columnType="STRING", maximumSize=as.integer(200))))
}

walkingActivitySchema<-function(projectId) {
	TableSchema("Walking Activity", projectId, list(
					TableColumn(name="recordId", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="healthCode", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="createdOn", columnType="DATE"),
					TableColumn(name="appVersion", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="phoneInfo", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="accel_walking_outbound.json.items", columnType="FILEHANDLEID"),
					TableColumn(name="deviceMotion_walking_outbound.json.items", columnType="FILEHANDLEID"),
					TableColumn(name="pedometer_walking_outbound.json.items", columnType="FILEHANDLEID"),
					TableColumn(name="accel_walking_return.json.items", columnType="FILEHANDLEID"),
					TableColumn(name="deviceMotion_walking_return.json.items", columnType="FILEHANDLEID"),
					TableColumn(name="pedometer_walking_return.json.items", columnType="FILEHANDLEID"),
					TableColumn(name="accel_walking_rest.json.items", columnType="FILEHANDLEID"),
					TableColumn(name="deviceMotion_walking_rest.json.items", columnType="FILEHANDLEID"),
					TableColumn(name="medTimepoint", columnType="STRING", maximumSize=as.integer(200))
			))
}

createOutputTables<-function(projectId) {
			synStore(demographicSurveySchema(projectId))
			synStore(updrsSurveySchema(projectId))
			synStore(pdq8SurveySchema(projectId))
			synStore(memoryActivitySchema(projectId))
			synStore(tappingActivitySchema(projectId))
			synStore(tappingLeftrightActivitySchema(projectId))
			synStore(voiceActivitySchema(projectId))
			synStore(walkingActivitySchema(projectId))
}

tappingFeatureSchema<-function(projectId) {
	TableSchema("Tapping Features", projectId, list(
					TableColumn(name="recordId", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="is_computed", columnType="BOOLEAN"),
					TableColumn(name="tap_count", columnType="INTEGER")
			))
}

tappingLeftFeatureSchema<-function(projectId) {
  TableSchema("Tapping Features - Left", projectId, list(
    TableColumn(name="recordId", columnType="STRING", maximumSize=as.integer(200)),
    TableColumn(name="is_computed", columnType="BOOLEAN"),
    TableColumn(name="tap_count", columnType="INTEGER")
  ))
}

tappingRightFeatureSchema<-function(projectId) {
  TableSchema("Tapping Features - Right", projectId, list(
    TableColumn(name="recordId", columnType="STRING", maximumSize=as.integer(200)),
    TableColumn(name="is_computed", columnType="BOOLEAN"),
    TableColumn(name="tap_count", columnType="INTEGER")
  ))
}

voiceFeatureSchema<-function(projectId) {
	TableSchema("Voice Features", projectId, list(
					TableColumn(name="recordId", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="is_computed", columnType="BOOLEAN"),
					TableColumn(name="medianF0", columnType="DOUBLE")
			))
}

balanceFeatureSchema<-function(projectId) {
	TableSchema("Balance Features", projectId, list(
					TableColumn(name="recordId", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="is_computed", columnType="BOOLEAN"),
					TableColumn(name="zcrAA", columnType="DOUBLE")
			))
}

gaitFeatureSchema<-function(projectId) {
	TableSchema("Gait Features", projectId, list(
					TableColumn(name="recordId", columnType="STRING", maximumSize=as.integer(200)),
					TableColumn(name="is_computed", columnType="BOOLEAN"),
					TableColumn(name="F0XY", columnType="DOUBLE")
			))
}

createFeatureTables<-function(projectId) {
	tfSchema<-synStore(tappingFeatureSchema(projectId))
	tlfSchema<-synStore(tappingLeftFeatureSchema(projectId))
	trfSchema<-synStore(tappingRightFeatureSchema(projectId))
	vfSchema<-synStore(voiceFeatureSchema(projectId))
	bfSchema<-synStore(balanceFeatureSchema(projectId))
	gfSchema<-synStore(gaitFeatureSchema(projectId))
	list(tfSchemaId=propertyValue(tfSchema, "id"), 
	     tlfSchemaId=propertyValue(tlfSchema, "id"), 
	     trfSchemaId=propertyValue(trfSchema, "id"), 
	     vfSchemaId=propertyValue(vfSchema, "id"), 
	     bfSchemaId=propertyValue(bfSchema, "id"), 
	     gfSchemaId=propertyValue(gfSchema, "id"))
}

# create 'lastProcessedFeatureVersion' table
createLastProcessedFeatureVersionTable<-function(project) {
	columns<-list(
			TableColumn(name="TABLE_ID", columnType="ENTITYID"), 
			TableColumn(name="FEATURE", columnType="STRING", maximumSize=as.integer(200)), 
			TableColumn(name="LAST_VERSION", columnType="INTEGER"),
			TableColumn(name="OUTPUT_TABLE_ID", columnType="ENTITYID"))
	schema<-TableSchema("Last Processed For Feature", project, columns)
	schema<-synStore(schema)
	# no content initially
	propertyValue(schema, "id")
}

# set up mPowerBatchStatusId
createVoiceBatchTable<-function(project) {
	c1<-TableColumn(name="batchNumber", columnType="INTEGER")
	c2<-TableColumn(name="batchStart", columnType="DATE")
	c3<-TableColumn(name="hostName", columnType="STRING")
	c4<-TableColumn(name="batchStatus", columnType="STRING")
	schema<-TableSchema("Voice Batch Status Schema", project, list(c1,c2,c3,c4))
	schema<-synStore(schema)
	propertyValue(schema, "id")
}

