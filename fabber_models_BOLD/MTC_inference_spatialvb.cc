/* what's going on in inference_spatialvb.cc

Don't actually try to compile this, its just for illustrating logical flow in the original program

MT Cherukara 

11:15, 16 June - Now that we've mapped out the main loop in spatialvb,
                    we must find a way to incorporate a skipping thing, like in inference_vb,
                    that will not freeze up when a voxel doesn't converge properly. 

*/
// Before main loop


//--------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------
void SpatialVariationalBayes::DoCalculations(const DataSet& allData)
{
const Matrix& data = allData.GetVoxelData();
const Matrix& coord = allData.GetVoxelCoords();
const Matrix& suppdata = allData.GetVoxelSuppData();
const int Nvoxels = data.Ncols();

// dummy data
model->pass_in_data( data.Column(1));
model->pass_in_coords(coords.Column(1));

const int Nparams = model->NumParams();

// Initialization

// Make the neighbours lists
if (spatialPriorsTypes.find_first_of("mMpPSZ") != string::npos)
{
    CalcNeighbours(allData.GetVoxelCoords());
}

// Make distributions
vector<NoiseParams*> noiseVox; 
vector<NoiseParams*> noiseVoxPrior; 
vector<MVNDist> fwdPriorVox;
vector<MVNDist> fwdPosteriorVox;
vector<LinearizedFwdModel> linearVox;

vector<MVNDist*> fwdPosteriorWithoutPrior(Nvoxels, (MVNDist*)NULL);

// locked linearization stuff (maybe)

const int nFwdParams = initialFwdPrior->GetSize();
const int nNoiseParams = initialNoisePrior->OutputAsMVN().GetSize();

noiseVox.resize(Nvoxels, NULL); // polymorphic type, so need to use pointers
noiseVoxPrior.resize(Nvoxels,NULL);
fwdPriorVox.resize(Nvoxels, *initialFwdPrior);
linearVox.resize(Nvoxels, LinearizedFwdModel(model) );
resultMVNs.resize(Nvoxels, NULL);

resultFs.resize(Nvoxels, 9999); // 9999 is a garbage default value

for (v = loop through voxels)
{
    linearVox[v-1].ReCentre(fwdPosteriorVox[v-1].means);
    noiseVox[v-1] = initialNoisePosterior->Clone();
    noiseVoxPrior[v-1] = initialNoisePrior->Clone();
    noise->Precalculate( *noiseVox[v-1], *noiseVoxPrior[v-1], data.Column(v));
}

DiagonalMatrix akmean(Nparams);
akmean = 1e-8;

DiagonalMatrix delta(Nparams);
DiagonalMatrix rho(Nparams);
delta = fixedDelta;
rho = 0;

vector<SymmetricMatrix> Sinvs(Nparams);
SymmetricMatrix StS;
const double globalF = 1234.5678;

if (StS.Nrows() == 0 && neighbours.size() > 0 && shrinkageType == 'S'
{
    assert((int)neighbours.size() == Nvoxels);
    const double tiny = 1e-6;
    StS.ReSize(Nvoxels);
    StS = 0;
    for (v = loop through voxels)
    {
        int Nv = neighbours[v-1].size();
        StS(v,v) = Nv + (Nv+tiny)*(Nv+tiny);
        
        for (nidIt = loop through neighbours)
        {
            if (v < *nidIt)
                StS(v,*nidIt) -= Nv + neighbours[*nidIt-1].size() + 2*tiny;
        }
        for (nidIt = loop through neighbours2)
        {
            if (v < *nidIt)
                StS(v,*nidIt) += 1;
        }
    }
} // if (StS.Nrows() == 0 && neighbours.size() > 0 && shrinkageType == 'S'

conv->Reset();
bool isFirstIteration = true;

// ---------------------------------------------------------------
// NEW STUFF - declare vectors in which data is saved, to be reverted to later
vector<MVNDist> fwdPosteriorVoxSave(fwdPosteriorVox);
vector<MVNDist> fwdPriorVoxSave(fwdPriorVox);
vector<NoiseParams*> noiseVoxSave;
noiseVoxSave.resize(Nvoxels, NULL);

for (int i = 1; i <= Nvoxels; i++)
{
	noiseVoxSave[i-1] = noiseVox[i-1]->Clone();
}
// ---------------------------------------------------------------

// Main loop
do
{
    if (!FirstIteration)
    {
        // Update shrinkage prior parameters
        DiagonalMatrix gk(Nparams);
        for (k = loop through parameters)
        {
            ColumnVector wk(Nvoxels);
            DiagonalMatrix sigmak(Nvoxels);
            for (v = loop through voxels)
            {
                // find mean value and standard deviation of previous voxel 
                wk(v) = fwdPosteriorVox.at(v-1).means(k);
                sigmak(v,v) = fwdPosteriorVox.at(v-1).GetCovariance()(k,k); 
            }
            
            switch (shrinkageType) {
            case 'S' { // we don't care about other spatial parameter types
                double tmp1 = 0.0;
                for (v = loop through voxels)
                {
                    int nn = neighbours.at(v-1).size();
                    tmp1 += sigmak(v,v) * ( (nn+1e-6)*(nn+1e-6) + nn);
                }
                
                ColumnVector Swk = 1e-6 * wk;
                
                for (v = loop through voxels)
                {
                    for (v2It = loop through neighbours)
                    {
                        Swk(v) += wk(v) - wk(*v2It);
                    }
                }
                
                double tmp2 = Swk.SumSquare();
                
                cout << k << tmp1 << tmp2;
                
                // calculate spatial prior akmean
                gk(k,k) = 1/(0.5*tmp1 + 0.5*tmp2 + 0.1);
                akmean(k) = gk(k) * (Nvoxels*0.5 + 1.0);
            }
            } // switch (shrinkageType) {
            
        } // for (k = loop through parameters)
        
        DiagonalMatrix akmeanMax = akmean * maxPrecisionIncreasePerIteration;
        
        for (k = loop through parameters)
        {
            // make sure akmean(k,k) doesn't get below 1e-50
        }
    } // if (!FirstIteration)

    // update DELTA and RHO
    for (k = loop through parameters)
    {
        switch (spatialPriorsTypes) {
            
        case 'S': {
            delta(k) = -3;
            rho(k) = 1234.5678;
        }
        
        case 'R' 'D' 'F': {
            
        }
        } // switch (spatialPriorsTypes)
    } // for (k = loop through parameters)

    // Calculate C^-1 for new DELTA:
    {
        // calculate Cinv
        for (k = loop through parameters)
        {
            if (delta(k) >= 0 )
            {
                Sinvs.at(k-1) = covar.GetCinv(delta(k)) * exp(rho(k));
                assert( SP( initialFwdPrior->GetPrecisions(), IdentityMatrix(Nparams)-1 ).MaximumAbsoluteValue() == 0);
                Sinvs[k-1] *= initialFwdPrior->GetPrecisions()(k,k);
            }
        } 
    } // Calculate C^-1 for new DELTA:
    
    /*
    // new: create vectors in which to save MVN dists
    vector<MVNDist> fwdPosteriorVoxSave;
    vector<MVNDist> fwdPriorVoxSave;
    vector<NoiseParams*> noiseVoxSave;
    // back to original: */

    // Iterate over voxels
    for (v = loop over voxels)
    {
        model->pass_in_data( data.Column(v) );
        model->pass_in_coords(coords.Column(v));
        
        double &F = resultFs.at(v-1);
        
        // if shrinkage type = 'S' (we don't care about other types)
        assert(StS.Nrows() == Nvoxels);
        
        double weight = 1e-6;
        ColumnVector contrib(Nparams);
        contrib = 0;
        
        for ( i = loop over voxels)
        {
            if (v != i)
            {
                weight += StS(v,i);
                contrib += StS(v,i) * fwdPosteriorVox[i-1].means;
            }
        }
        
		 // ---------------------------------------------------------------
		 // NEW STUFF - revert and save, if necessary, for each voxel
		 
		 if (conv->NeedRevert())
		 {
			 fwdPosteriorVox[v-1] = fwdPosteriorVoxSave[v-1];
			 fwdPriorVox[v-1] = fwdPriorVoxSave[v-1];
			 *noiseVox[v-1] = *noiseVoxSave[v-1];
		 }
		 
		 if (conv->NeedSave())
		 { 
			 fwdPosteriorVoxSave[v-1] = fwdPosteriorVox[v-1];
			 fwdPriorVoxSave[v-1] = fwdPriorVox[v-1];
			 *noiseVoxSave[v-1] = *noiseVox[v-1];
		 }
		 // ---------------------------------------------------------------
        
        DiagonalMatrix spatialPrecisions;
        spatialPrecisions = akmean * StS(v,v);
        
        fwdPriorVox[v-1].SetPrecisions(spatialPrecisions);
        fwdPriorVox[v-1].means = contrib / weight;
        
        // end if shrinkage type = 'S'
        
        double Fard = 0;
        
        // ---------------------------------------------------------------
        // NEW STUFF - start TRY here
        try 
        {
        // ---------------------------------------------------------------
        
        
        if (1)
        {
           
            // marginalize out all other voxels 
            DiagonalMatrix spatialPrecisions(Nparams);
            ColumnVector weightedMeans(Nparams);
            ColumnVector priorMeans(Nparams);
            priorMeans = initialFwdPrior->means; // this will be ignored for spatial priors 
            
            for (k = loop over params)
            {
                spatialPrecisions(k) = -9999; // when spatialPriorsTypes == shrinkageType
                weightedMeans(k) = -9999;
            } 
            
            assert(initialFwdPrior->GetPrecisions().Nrows() == spatialPrecisions.Nrows());
            DiagonalMatrix finalPrecisions = spatialPrecisions;
            ColumnVector finalMeans = priorMeans - spatialPrecisions.i() * weightedMeans;
            
            for (k = loop over parameters)
            {
                finalPrecisions(k) = fwdPriorVox[v-1].GetPrecisions()(k,k);
                finalMeans(k) = fwdPriorVox[v-1].means(k);
                fwdPriorVox[v-1].SetPrecisions( finalPrecisions );
                fwdPriorVox[v-1].means = finalMeans;
            }
        } // if (1)
        
        
        noise->UpdateTheta( *noiseVox[v-1],fwdPosteriorVox[v-1], fwdPriorVox[v-1], linearVox[v-1], 
                            data.Column(v), fwdPosteriorWithoutPrior.at(v-1));
                            
        // ---------------------------------------------------------------
        // NEW STUFF - end of try, and catches
        } // TRY   
        catch (const overflow_error& e)
        {
            LOG_ERR("    Went infinite!  Reason:" << endl << "      " << e.what() << endl);
            if (haltOnBadVoxel) throw;
            LOG_ERR("    Going on to the next voxel." << endl);
        }    
        catch (Exception)
        {
            LOG_ERR("    NEWMAT Exception in this voxel:\n" << Exception::what() << endl);
            if (haltOnBadVoxel) throw;
            LOG_ERR("    Going on to the next voxel." << endl);
        }
        catch (...)
        {
            LOG_ERR("    Other exception caught in main calculation loop!!\n");
            if (haltOnBadVoxel) throw;
            LOG_ERR("    Going on to the next voxel." << endl);
        } 
        // ---------------------------------------------------------------
                            
    }// for (v = loop over voxels)

    for (v = loop over voxels)
    {
                            
        model->pass_in_data( data.Column(v));
        model->pass_in_coords(coords.Column(v));
        
        double &F = resultsFs.at(v-1);
        
        // ---------------------------------------------------------------
        // NEW STUFF - try and catch on UpdateNoise and ReCentre.
        try
        {
        noise->UpdateNoise( *noiseVox[v-1], *noiseVoxPrior[v-1], fwdPosteriorVox[v-1], 
                            linearVox[v-1], data.Column(v) );
                            
        if (!lockedLinearEnabled) // don't know if this is a thing or not
            linearVox[v-1].ReCentre( fwdPosteriorVox[v-1].means );
        } // TRY
        catch (const overflow_error& e)
        {
	        LOG_ERR("    Went infinite!  Reason:" << endl << "      " << e.what() << endl);
	        if (haltOnBadVoxel) throw;
	        LOG_ERR("    Going on to the next voxel." << endl);
        }    
        catch (Exception)
        {
            LOG_ERR("    NEWMAT Exception in this voxel:\n" << Exception::what() << endl);
            if (haltOnBadVoxel) throw;
            LOG_ERR("    Going on to the next voxel." << endl);
        }
        catch (...)
        {
            LOG_ERR("    Other exception caught in main calculation loop!!\n");
            if (haltOnBadVoxel) throw;
            LOG_ERR("    Going on to the next voxel." << endl);
        }
        // ---------------------------------------------------------------
        
    } // for (v = loop over voxels)

    isFirstIteration = false;

} while (!conv->Test( globalF));

// after main loop

// ---------------------------------------------------------------
// NEW STUFF - revert again if necessary

if (conv->NeedRevert())
{
    fwdPriorVox = fwdPriorVoxSave;
    fwdPosteriorVox = fwdPosteriorVoxSave;

    for (int i = 1; i <= Nvoxels; i++)
    {
        noiseVox[i-1] = noiseVoxSave[i-1];
    }
}
// ---------------------------------------------------------------

} // DoCalculations