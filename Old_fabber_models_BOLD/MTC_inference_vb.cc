/* what's going on in inference_vb.cc

Don't actually try to compile this, its just for illustrating logical flow in the original program

MT Cherukara 

*/

// initialize
void VariationalBayesInferenceTechnique::Initialize(FwdModel* fwd_model, ArgsType& args) 
{
haltOnBadVoxel = !args.ReadBool("allow-bad-voxels");
// this is declared in header (inference_vb.h)
// protected: bool haltOnBadVoxel 
}

// DoCalculations
void VariationalBayesInferenceTechnique::DoCalculations(const DataSet& allData)
{

const Matrix& origdata = allData.GetVoxelData();
const Matrix& coords = allData.GetVoxelCoords();
const Matrix& suppdata = allData.GetVoxelSuppData();

// dummy data
model->pass_in_data(origdata.Column(1));
model->pass_in_coords(coords.Column(1));

int Nvoxels = origdata.Nrows();

Matrix data(origdata.Nrows((),Nvoxels);
data = origdata;
Matrix modelpred(model->NumOutputs(),Nvoxels);

asser(resultMVNs.empty());
resultMVNs.resize(Nvoxels,NULL);

assert(resultFs.empty());
resultFs.resize(Nvoxels,9999);

const int nFwdParams = initialFwdPrior->GetSize();
const int nNoiseParams = initialNoisePrior->OutputAsMVN().GetSize();

bool continuefromprevious = false;

// MAIN LOOP (ignore motion correction steps)
for (voxel = Nvoxels)
{
    ColumnVector y = data.Column(voxel);
    ColumnVector vcoords = coords.Column(voxel);
    
    model->pass_in_data(y);
    model->pass_in_coords(vcoords);
    NoiseParams* noiseVox = NULL;
    
    if (continuefromprevious)
    {
        noiseVox = noise->NewParams();
        noiseVox->InputFromMVN( resultMVNs.at(voxel-1)->GetSubmatrix(nFwdParams+1, nFwdParams+nNoiseParams) );
    }
    else // first time 
    {
        noiseVox = initialNoisePosterior->Clone();
    }
    
    const NoiseParams* noiseVoxPrior = initialNoisePrior;
    NoiseParams* const noiseVoxSave = noiseVox->Clone;
    
    double F = 1234.5678;
    
    MVNDist fwdPrior(*initialFwdPrior);
    MVNDist fwdPosterior;
    
    if (continuefromprevious)
    {
        fwdPosterior = resultMVNs.at(voxel-1)->GetSubmatrix(1, nFwdParams);
    }
    else // first time 
    {
        assert(initialFwdPosterior != NULL);
        fwdPosterior = *initialFwdPosterior;
    }    
    
    model->InitParams(fwdPosterior);
    
    MVNDist fwdPosteriorSave(fwdPosterior);
    MVNDist fwdPriorSave(fwdPrior);
    
    LinearizedFwdModel linear(model);
    
    double Fard = 0;
    model->SetupARD(fwdPosterior, fwdPrior, Fard);
    Fard = noise->SetupARD( model->ardindices, fwdPosterior, fwdPrior);
    
    try
    {
        linear.ReCentre (fwdPosterior.means);
        
        noise->Precalculate( *noiseVox, *noiseVoxPrior, y);
        
        conv-> Reset();
        
        int iteration 0;
        
        // MAIN LOOP FOR THIS VOXEL
        do // while ( !conv->Test( F ) ); 
        {
            // revert if necessary
            if (conv->NeedRevert())
            {
                *noiseVox = *noiseVoxSave;
                fwdPosterior = fwdPosteriorSave;
                fwdPrior = fwdPriorSave;
                linear.ReCentre(fwdPosterior.means);
            }
            
            // save values if necessary
            if (conv->NeedSave())
            {
                *noiseVoxSave = *noiseVox;
                fwdPosteriorSave = fwdPosterior;
                fwdPriorSave = fwdPrior;
            }
            
            if (iteration > 0)
            {
                model->UpdateARD( fwdPosterior, fwdPrior, Fard);
                Fard = noise->UpdateARD(model->ardindices, fwdPosterior, fwdPrior);
            }
            
            noise->UpdateTheta( *noiseVox, fwdPosterior, fwdPrior, linear, y, NULL, conv->LMalpha() );
            
            noise->UpdateNoise( *noiseVox, fwdPosterior, fwdPrior, linear, y );
            
            linear.ReCentre( fwdPosterior.means );
            
            iteration++;
        }
        while ( !conv->Test( F ) );
        
        if ( conv->NeedRevert())
        {
            *noiseVox = *noiseVoxSave;
            fwdPosterior = fwdPosteriorSave;
            fwdPrior = fwdPriorSave;
            linear.ReCentre(fwdPosterior.means);
        }
    } // try
    
    catch (overflow)
    {
        LOG_ERR("Overflow");
        if (haltOnBadVoxel) throw;
    }
    catch (Exception);
    {
        LOG_ERR("Exception");
        if (haltOnBadVoxel) throw;
    }
    catch (...)
    {
        LOG_ERR("...");
        if (haltOnBadVoxel) throw;
    }   
    
    // write results
    
    // then delete
    delete noiseVox; noiseVox = NULL;
    delete noiseVoxSave;
    
    continuefromprevious = true;
    
    
} // for (voxel = Nvoxels)



} // DoCalculations