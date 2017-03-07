/*  easylog.cc - a fairly minimal logging-to-file implementation

    Adrian Groves, FMRIB Image Analysis Group

    Copyright (C) 2007-2008 University of Oxford  */

/*  CCOPYRIGHT */

#include "easylog.h"
#include "easyoptions.h"
#include "assert.h"
#include <stdexcept>
#include <fstream>
#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>

ostream* EasyLog::filestream = NULL;
string EasyLog::outDir = "";

void EasyLog::StartLog(const string& basename, bool overwrite)
{
  assert(filestream == NULL);
  assert(basename != "");
  outDir = basename;

  // From Wooly's utils/log.cc
  int count = 0;
  while(true)
    {
      if(count >= 50) // I'm using a lot for some things
	{
	  throw Runtime_error(("Cannot create directory (bad path, or too many + signs?):\n    " + outDir).c_str());
	}
      
      // not portable!
      //int ret = system(("mkdir "+ outDir + " 2>/dev/null").c_str());

      // Is this portable?
      errno = 0; // Clear errno so it can be inspected later; result is only meaningful if mkdir fails.
      int ret = mkdir(outDir.c_str(), 0777);

      if(ret == 0) // Success, directory created
	  break;
      else if (overwrite)
        {
          if (errno == EEXIST) // Directory already exists -- that's fine.  Although note it might not be a directory.
            break;
          else // Other error -- might be a problem!
            throw Runtime_error(("Unexpected problem creating directory in --overwrite mode:\n    " + outDir).c_str());
        }

      outDir += "+";
      count++;
    }

  filestream = new ofstream( (outDir + "/logfile").c_str() );

  if (!filestream->good())
    {
      delete filestream; 
      filestream = NULL;
      cout << "Cannot open logfile in " << outDir;
      throw runtime_error("Cannot open logfile!");
    }

  // Might be useful for jobs running on the queue:
  system( ("uname -a > " + outDir + "/uname.txt").c_str() );

  // try to make a link to the latest version
  // REMOVED because it's annoying, not terribly useful, and implemented 
  // badly (only really works output dir is in current dir).
  // PUT BACK because Michael uses it and finds it useful!
  system(("ln -sfn '" + outDir + "' '" + basename + "_latest'").c_str());
  // If this fails, it doesn't really matter.  This'll fail (hopefully silently) in Windows.
}

void EasyLog::StartLogUsingStream(ostream& s)
{
  assert(filestream == NULL);
  filestream = &s;
  outDir = "";
}

void EasyLog::StopLog(bool gzip)
{
  assert(filestream != NULL);

  if (outDir != "") // we created this ofstream
    delete filestream;

  filestream = NULL; // release the stream

  if (gzip)
    {
      int retVal = system(("gzip " + outDir + "/logfile").c_str());
      if (retVal != 0)
	cout << "Failed to gzip logfile.  Oh well." << endl;
    }

  outDir = "";
}


// Basically a private global variable, initially empty:
map<string,int> Warning::issueCount;

// Note that we have to use LOG_ERR_SAFE because warnings could be issued when there's no valid logfile yet.

void Warning::IssueOnce(const string& text)
{
  if (++issueCount[text] == 1)
    LOG_ERR_SAFE("WARNING ONCE: " << text << endl);
}

void Warning::IssueAlways(const string& text)
{
  ++issueCount[text];
  LOG_ERR_SAFE("WARNING ALWAYS: " << text << endl);
}

void Warning::ReissueAll()
{
  if (issueCount.size() == 0) 
    return; // avoid issuing pointless message

  LOG_ERR_SAFE("\nSummary of warnings (" << issueCount.size() << " distinct warnings)\n");
  for (map<string,int>::iterator it = issueCount.begin();
       it != issueCount.end(); it++)
    LOG_ERR_SAFE("Issued " << 
	    ( (it->second==1)?
	      "once: " :
	      stringify(it->second)+" times: "
	      ) << it->first << endl);
}