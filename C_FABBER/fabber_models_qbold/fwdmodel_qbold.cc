/*   fwdmodel_qbold.cc - Implements the ASE qBOLD curve fitting model

 Matthew Cherukara, IBME

 Copyright (C) 2017 University of Oxford  */

#include "fwdmodel_qbold.h"

#include "fabber_core/fwdmodel.h"

#include <math.h>
#include <iostream.h>

using namespace std;
using namespace NEWMAT;

// ------------------------------------------------------------------------------------------
// --------         Generic Methods             ---------------------------------------------
// ------------------------------------------------------------------------------------------
FactoryRegistration<FwdModelFactory, QBoldFwdModel> QBoldFwdModel::registration("qbold");

FwdModel *QBoldFwdModel::NewInstance() // unchanged
{
    return new QBoldFwdModel();
} // NewInstance

string QBoldFwdModel::GetDescription() const 
{
    return "ASE qBOLD model";
} // GetDescription

string QBoldFwdModel::ModelVersion() const
{
    return "1.0";
} // ModelVersion

static OptionSpec OPTIONS[] = {
    { "use-offset", OPT_BOOL, "If True, allow an additional constant offset parameter", OPT_NONREQ, "false" },
    { "" }
};

void QBoldFwdModel::GetOptions(vector<OptionSpec> &opts) const
{
    for (int i = 0; OPTIONS[i].name != ""; i++)
    {
        opts.push_back(OPTIONS[i]);
    }
} // GetOptions

// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void QBoldFwdModel::Initialize(ArgsType &args)
{
    // read through input arguments using &args
    TE = convertTo<double>(args.ReadWithDefault("TE","0.074"));

    // collect tau values
    string tau_temp;

    // this parses through the input args for tau1=X, tau2=X and so on, until it reaches a
    // tau that isn't supplied in the argument, and it adds all these to the ColumnVector
    // called tau_list
    while (true)
    {
        int N = tau_list.Nrows()+1;
        tau_temp = args.ReadWithDefault("tau"+stringify(N), "stop!");
        if (tau_temp == "stop!") break;

        ColumnVector tmp(1);
        tmp = convertTo<double>(tau_temp);
        tau_list &= tmp;
    }

    taus = tau_list; // why is this necessary?
    
} // Initialize


// ------------------------------------------------------------------------------------------
// --------         Defining Parameters       ---------------------------------------------
// ------------------------------------------------------------------------------------------
int QBoldFwdModel::NumParams() const
{
    if (m_include_offset)
        return 4;
    else
        return 3;
} // NumParams

void QBoldFwdModel::NameParams(vector<string> &names) const
{
    names.clear();
    names.push_back("a");
    names.push_back("b");
    names.push_back("c");
    if (m_include_offset)
        names.push_back("d");
} // NameParams

// ------------------------------------------------------------------------------------------
// --------         HardcodedInitialDists       ---------------------------------------------
// ------------------------------------------------------------------------------------------
void QBoldFwdModel::HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const
{
    int num_params = NumParams();
    // Check we have been given a distribution of the right number of parameters
    assert(prior.means.Nrows() == num_params);
    prior.means = 1;
    prior.SetPrecisions(IdentityMatrix(num_params) * 1e-12);
    posterior = prior;

} // HardcodedInitialDists

// ------------------------------------------------------------------------------------------
// --------         Evaluate                    ---------------------------------------------
// ------------------------------------------------------------------------------------------
void QBoldFwdModel::Evaluate(const ColumnVector &params, ColumnVector &result) const
{
    // Check we have been given the right number of parameters
    assert(params.Nrows() == NumParams());
    result.ReSize(data.Nrows());

    for (int i = 1; i <= data.Nrows(); i++)
    {
        float t = float(i) / data.Nrows();
        double res = params(1) * sin(params(2) * (t - params(3)));
        if (m_include_offset)
            res += params(4);
        result(i) = res;
    } // for (int i = 1; i <= data.Nrows(); i++)

} // Evaluate
