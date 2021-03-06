#' R Interface for 'cdo.sellonlatbox' and 'cdo.distgrid'
#' 
#' @param x input netcdf file for 'cdo.sellonlatbox' and the 'cdo.distgrid'
#' @param y extent or \code{Extent*} object indicateing the extent to extract or \code{NULL}(dafault). It works with \code{sellonlatbox==TRUE}.
#' @param sellonlatbox logical value. if it is \code{TRUE} (default) , \code{x} is cropped through \code{\link{cdo.sellonlatbox}} 
#' @param outdir,outfile output directory and/or output file
#' @param return.raster logical value. If is \code{TRUE}, outputs are returned as \code{\link{RasterStack-class}} objects.
#' @param dim integer vector reporting the number of rows and columuns of the matrix of tiles into which the cropped map is spit. 
#' @param ... further arguments for \code{\link{cdo.sellonlatbox}}
#' 
#' @seealso \code{\link{cdo.sellonlatbox}}
#' @importFrom raster 'extension<-'
#' @export
#' @examples 
#' 
#' 
#' 
#' \dontrun{
#' 
#'  ncname <- "chirps-v2.0.2005.days_p05.nc"
#'  url <- "ftp://ftp.chg.ucsb.edu/pub/org/chg/products/CHIRPS-2.0/global_daily/netcdf/p05"
#'  temp <- tempdir()
#'  x <- paste(temp,ncname,sep="/")
#'  download.file(url=paste(url,ncname,sep="/"),destfile=x)
#' 
#' 
#' 
#' 
#' ### Africa Extent: extent      : -18.1625, 54.5375, -34.8375, 37.5625  (xmin, xmax, ymin, ymax)
#' ###y <- extent(c(-17.6608, -5.727799, 10.17488, 18.62197)) ## Extent senegal
#'  y <- extent(c(-18.1625,54.5375,-34.8375,37.5625))
#' 
#'  prec_afr <- cdo.distgrid(x=x,y=y,dim=c(10,10),parallel=TRUE)	
#' 
#' 
#' }

cdo.distgrid <-function(x,y=NULL,...,outdir=NULL,outfile=NULL,dim=c(1,1),sellonlatbox=TRUE,return.raster=TRUE)  {
	
	if (is.null(y)) sellonlatbox <- FALSE
	
	if (sellonlatbox==TRUE) { 
		
		out <- cdo.sellonlatbox(x,y,...,outdir=outdir,outfile=outfile,dim=c(1,1),return.raster=FALSE)
		obase <- out
	} else {
		
		if (is.null(outfile)) outfile <- NA
		if (is.na(outfile)) outfile <- "default"
		if (is.null(outdir)) outdir <- NA
		if (is.na(outdir)) outdir <- "default"
		
		if (outdir=="default") outdir <- tempdir()
		if (outfile=="default") {
			
			outfile <- basename(x)
			outfile <- paste(outdir,outfile,sep="/")
			#suffix <- paste0("__",ys,".nc")
			#outfile <- str_replace(basename(x),".nc",suffix)
			#if (outdir!="")  outfile <- paste(outdir,outfile,sep="/")
			
			
			
		}
		out <- x
		obase <- outfile
	}	
	
	infile <- out
	
	###obase <- out
	extension(obase) <- ""
	
	obase <- paste(obase,"tile",sprintf("nx%03d",dim[2]),sprintf("ny%03d",dim[1]),"",sep="_")

	rdims <- paste(rev(dim),collapse=",") 
	
	cdostring <- sprintf('cdo distgrid,%s %s %s',rdims,infile,obase)
	
	message(cdostring)
	out <- system(cdostring)
	## ref see https://code.mpimet.mpg.de/projects/cdo/embedded/cdo.pdf page 37	
	if (out==0) {
		
		 dirf <- dirname(obase)
		 pattern <- basename(obase)		
		 out <- list.files(dirf,pattern=pattern,full.names=TRUE)	
		
			if (return.raster==TRUE) {
				
				out <- lapply(X=out,FUN=stack)
				
			}
		
	}
		
		
	
	return(out)
	
	
	
}