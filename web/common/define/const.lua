local const = {}

const.HTTP_METHODS = {}
const.HTTP_METHODS.GET = "GET"
const.HTTP_METHODS.HEAD = "HEAD"
const.HTTP_METHODS.POST = "POST"
const.HTTP_METHODS.PUT = "PUT"
const.HTTP_METHODS.DELETE = "DELETE"
const.HTTP_METHODS.OPTIONS = "OPTIONS"

-- subset of total content-type
-- reference:https://stackoverflow.com/questions/23714383/what-are-all-the-possible-values-for-http-content-type-header
const.extension2content_type = {
	jpg  = "image/jpeg",
	gif  = "image/gif",
	png  = "image/png",
	tiff = "image/tiff",
	css  = "text/css",
	csv  = "text/csv",
	html = "text/html",
	js   = "text/javascript (obsolete)",
	xml  = "text/xml",
	json = "application/json",
	pdf  = "application/pdf",
	ogg  = "application/ogg",
	zip  = "application/zip",
}

return const