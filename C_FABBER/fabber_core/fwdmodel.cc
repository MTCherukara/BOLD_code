/*  fwdmodel.cc - base class for generic forward models

 Adrian Groves and Michael Chappell, FMRIB Image Analysis Group & IBME QuBIc Group

 Copyright (C) 2007-2015 University of Oxford  */

/*  CCOPYRIGHT */

#include "fwdmodel.h"

#include "easylog.h"
#include "rundata.h"

#include <newmat.h>

#include <memory>
#include <sstream>
#include <string>
#include <vector>

using namespace std;

typedef int (*GetNumModelsFptr)(void);
typedef const char *(*GetModelNameFptr)(int);
typedef NewInstanceFptr (*GetNewInstanceFptrFptr)(const char *);

#ifdef _WIN32
// This stops Windows defining a load of macros which clash with FSL
#define WIN32_LEAN_AND_MEAN
#include "windows.h"
#define GETSYMBOL GetProcAddress
#define GETERROR GetLastErrorAsString

string GetLastErrorAsString()
{
    //Get the error message, if any.
    DWORD errorMessageID = ::GetLastError();
    if (errorMessageID == 0)
        return std::string(); //No error message has been recorded

    LPSTR messageBuffer = nullptr;
    size_t size = FormatMessageA(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL, errorMessageID, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPSTR)&messageBuffer, 0, NULL);

    std::string message(messageBuffer, size);

    //Free the buffer.
    LocalFree(messageBuffer);

    return message;
}
#else
// POSIX-style methods for shared libraries
#include <dlfcn.h>
#define GETSYMBOL dlsym
#define GETERROR dlerror
#endif

void FwdModel::LoadFromDynamicLibrary(const std::string &filename, EasyLog *log)
{
    FwdModelFactory *factory = FwdModelFactory::GetInstance();
    GetNumModelsFptr get_num_models;
    GetModelNameFptr get_model_name;
    GetNewInstanceFptrFptr get_new_instance_fptr;
    if (log)
        log->LogStream() << "Loading dynamic models from " << filename << endl;

#ifdef _WIN32
    HINSTANCE libptr = LoadLibrary(filename.c_str());
#else
    void *libptr = dlopen(filename.c_str(), RTLD_NOW);
#endif
    if (!libptr)
    {
        throw InvalidOptionValue("loadmodels", filename, string("Failed to open library ") + GETERROR());
    }

    get_num_models = (GetNumModelsFptr)GETSYMBOL(libptr, "get_num_models");
    if (!get_num_models)
    {
        throw InvalidOptionValue("loadmodels", filename,
            string("Failed to resolve symbol 'get_num_models' ") + GETERROR());
    }

    get_model_name = (GetModelNameFptr)GETSYMBOL(libptr, "get_model_name");
    if (!get_model_name)
    {
        throw InvalidOptionValue("loadmodels", filename,
            string("Failed to resolve symbol 'get_model_name' ") + GETERROR());
    }

    get_new_instance_fptr = (GetNewInstanceFptrFptr)GETSYMBOL(libptr, "get_new_instance_func");
    if (!get_new_instance_fptr)
    {
        throw InvalidOptionValue("loadmodels", filename,
            string("Failed to resolve symbol 'get_new_instance_func' ") + GETERROR());
    }

    int num_models = get_num_models();
    if (log)
        log->LogStream() << "Loading " << num_models << " models" << endl;
    for (int i = 0; i < num_models; i++)
    {
        const char *model_name = get_model_name(i);
        if (!model_name)
        {
            throw InvalidOptionValue("loadmodels", filename,
                "Dynamic library failed to return model name for index " + stringify(i));
        }
        else
        {
            if (log)
                log->LogStream() << "Loading model " << model_name << endl;
            NewInstanceFptr new_instance_fptr = get_new_instance_fptr(model_name);
            if (!new_instance_fptr)
            {
                throw InvalidOptionValue("loadmodels", filename,
                    string("Dynamic library failed to return new instance function for model") + model_name);
            }
            factory->Add(model_name, new_instance_fptr);
        }
    }
}

std::vector<std::string> FwdModel::GetKnown()
{
    FwdModelFactory *factory = FwdModelFactory::GetInstance();
    return factory->GetNames();
}

FwdModel *FwdModel::NewFromName(const string &name)
{
    FwdModelFactory *factory = FwdModelFactory::GetInstance();
    FwdModel *model = factory->Create(name);
    if (model == NULL)
    {
        throw InvalidOptionValue("model", name, "Unrecognized forward model");
    }
    return model;
}

void FwdModel::Initialize(FabberRunData &args)
{
    m_log = args.GetLogger();
}

void FwdModel::UsageFromName(const string &name, std::ostream &stream)
{
    stream << "Description: " << name << endl
           << endl;
    std::auto_ptr<FwdModel> model(NewFromName(name));
    stream << model->GetDescription() << endl
           << endl
           << "Options: " << endl
           << endl;
    vector<OptionSpec> options;
    model->GetOptions(options);
    if (options.size() > 0)
    {
        for (vector<OptionSpec>::iterator iter = options.begin(); iter != options.end(); ++iter)
        {
            stream << *iter;
        }
    }
    else
    {
        model->Usage(stream);
    }
}

string FwdModel::ModelVersion() const
{
    // You should overload this function in your FwdModel class
    return "No version info available.";
}

void FwdModel::Usage(std::ostream &stream) const
{
    stream << "No usage information available" << endl;
}

bool FwdModel::Gradient(const NEWMAT::ColumnVector &params, NEWMAT::Matrix &grad) const
{
    // By default return false -> no gradient is supplied by this model
    return false;
}

void FwdModel::DumpParameters(const NEWMAT::ColumnVector &params, const string &indent) const
{
    LOG << indent << "Parameters:" << endl;
    vector<string> names;
    NameParams(names);
    assert(names.size() == params.Nrows());

    for (size_t i = 1; i <= names.size(); i++)
        LOG << indent << "  " << names[i - 1] << " = " << params(i) << endl;

    LOG << indent << "Total of " << names.size() << " parameters" << endl;
}

void FwdModel::pass_in_coords(const NEWMAT::ColumnVector &coords)
{
    coord_x = coords(1);
    coord_y = coords(2);
    coord_z = coords(3);
}