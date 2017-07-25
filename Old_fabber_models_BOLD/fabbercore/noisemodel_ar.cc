/*  noisemodel_ar.cc - Class implementation for the AR(1) noise model

    Adrian Groves and Michael Chappell, FMRIB Image Analysis Group & IBME QuBIc Group

    Copyright (C) 2007-2015 University of Oxford  */

/*  CCOPYRIGHT */

#include "noisemodel_ar.h"
#include <stdexcept>
#include "miscmaths/miscmaths.h"
using namespace MISCMATHS;
using namespace Utilities;
#include "easylog.h"

#define AR1_BANDWIDTH 3
// Good enough for AR(1) with covariance terms
// Reason: regular AR(1) matrix R has stuff only in -2.  
// R'*R are oppositely oriented so +/- 2 is still good enough.  
// Covariance terms are at +/-1, so maximum possible offset from
// the main diagonal is +/-3.   

NoiseModel* Ar1cNoiseModel::NewInstance()
{
  return new Ar1cNoiseModel();
}

/*Ar1cNoiseModel* Ar1cNoiseModel::Clone() const
{
  Ar1cNoiseModel* clone = new Ar1cNoiseModel(ar1Type, nPhis);
  clone->prior = new Ar1cParameters(*prior);
  clone->posterior = new Ar1cParameters(*posterior);
  clone->alphaMat = alphaMat;

  return clone;
}*/

void Ar1cNoiseModel::Initialize(ArgsType& args)
{
  string nPhisString = args.ReadWithDefault("num-echoes","(default)");
  if (nPhisString == "(default)")
  {
      nPhis = 1;
      Warning::IssueOnce("Defaulting to --num-echoes=1");
  }
  else
  {
      nPhis = convertTo<int>(nPhisString);
  }
  ar1Type = args.ReadWithDefault("ar1-cross-terms","none");
  // Validate ar1Type:
  NumAlphas(); // throws exception if ar1Type is invalid
  // Validate nPhis
  if (nPhis==1)
  {
    if (ar1Type != "none")
      throw Invalid_option("You must use --ar1-cross-terms=none with --num-echoes=1");
    else
      LOG_ERR("WARNING: using --num-echoes=1 is completely untested!\nIt will probably give completely the wrong answers or crash!\n");            
  }        
  else if (nPhis==2)
  { } // ok
  else            
    throw Invalid_option("--num-echoes must be 1 or 2");
}

// Just convert a string into a number
int Ar1cNoiseModel::NumAlphas() const
{
    Tracer_Plus("Ar1cNoiseModel::NumAlphas");
    if (ar1Type == "same")
        return 3;
    else if (ar1Type == "dual")
        return 4;
    else if (ar1Type == "none")
        return 2;
    else  
        throw Logic_error("Invalid ar1Type -- shouldn't make it this far!");
}

void Ar1cNoiseModel::HardcodedInitialDists(NoiseParams& priorIn, NoiseParams& posteriorIn) const
{
    Tracer_Plus tr("Ar1cNoiseModel::HardcodedInitialDists");

    Ar1cParams& prior = dynamic_cast<Ar1cParams&>(priorIn);
    Ar1cParams& posterior = dynamic_cast<Ar1cParams&>(posteriorIn);

    const int nAlphas = NumAlphas();
    
    assert(prior.alpha.means.Nrows() == nAlphas);
    assert(posterior.alpha.means.Nrows() == nAlphas);
    assert(prior.phis.size() == (unsigned)nPhis);
    assert(posterior.phis.size() == (unsigned)nPhis);

	prior.alpha.means = 0;
    posterior.alpha.means = 0;
	prior.alpha.SetPrecisions(IdentityMatrix(nAlphas) * 1e-4); // was 1e-6
    posterior.alpha.SetPrecisions(IdentityMatrix(nAlphas) * 1e-4);
	for (unsigned i = 1; i <= prior.phis.size(); i++) 
    {
        prior.phis[i-1].b = 1e6;
        prior.phis[i-1].c = 1e-6;
        posterior.phis[i-1].b = 1e-8; // Bit of black magic... tiny initial noise precision seems to help
        posterior.phis[i-1].c = 1e-6;
    }       
}


// Helper class for UpdateAlpha (could be used elsewhere)
// Evaluates (k' * ?? * k) + Trace(inv(L) * J' * ?? * J) for 
// a symmetric band ??.
class OperatorKLJ {
public:
  OperatorKLJ(const ColumnVector& k2, const SymmetricMatrix&L2, const Matrix& J2)
    : k(k2), L(L2), J(J2) { return; }
//    : k(k2), JLiJt(J2.Ncols(), AR1_BANDWIDTH)
//        { Tracer_Plus tr("OperatorKLJ::OperatorKLJ");
//            JLiJt << (J2*L2.i()*J2.t()); 
//            // the above doesn't work... should be some sort of lossy store, but
//            // it crashes with an "Undefined bandwidth" error... not sure why.
//            // Could always calculate it as a SymmetricMatrix then manually
//            // (i.e. in a loop) copy the near-diagonal bit to a
//            // a SymmetricBandMatrix -- so much hassle!) 
//        } 

  double operator()(const SymmetricBandMatrix& input) const;

private:
  const ColumnVector& k;
  const SymmetricMatrix& L;
  const Matrix& J;
//  SymmetricBandMatrix JLiJt;
};

double OperatorKLJ::operator()(const SymmetricBandMatrix& input) const
{ 
  Tracer_Plus tr("OperatorKLJ::operator()");
  
//  assert(input.BandWidth().Lower() <= AR1_BANDWIDTH);
//  return (k.t() * input * k).AsScalar()
//      + (input * JLiJt).Trace(); 
  return (k.t() * input * k).AsScalar()
      + (L.i() * J.t() * input * J).Trace(); 
  // Could precalculate J * L.i() * J.t(), but that's a big matrix 
  // to store so I'm not sure if it'd actually be better.
  // Now, since trace(A*B) = sum(sum(A.*B')), we only need to keep the elements
  // on the band... if we know the bandwidth in advance (and can be bothered!)
  // Turns out to be quite tricky in NEWMAT.  There's no obvious way to convert
  // a SymmetricMatrix into a SymmetricBandMatrix (i.e. it's lossy)
}


void Ar1cNoiseModel::UpdateAlpha(
    NoiseParams& noise, 
    const NoiseParams& noisePrior, 
  	const MVNDist& theta,
  	const LinearFwdModel& linear,
  	const ColumnVector& data) const
{
  Tracer_Plus tr("Ar1cNoiseModel::UpdateAlpha");

  Ar1cParams& posterior = dynamic_cast<Ar1cParams&>(noise);
  const Ar1cParams& prior = dynamic_cast<const Ar1cParams&>(noisePrior);  
  Ar1cMatrixCache& alphaMat = posterior.alphaMat;

  const int nNoiseModels = posterior.phis.size();
  //unused: const int nTimes = data.Nrows() / nPhis; 
  const unsigned nAlphas = prior.alpha.means.Nrows();
  assert(nNoiseModels == nPhis);  // the only size currently supported
  
  const Matrix& J = linear.Jacobian();
  const ColumnVector k = 
    data - linear.Offset() + J*(linear.Centre() - theta.means);

  ColumnVector si_ci(nNoiseModels);  
  for (int i = 1; i <= nNoiseModels; i++)
    si_ci(i) = posterior.phis[i-1].b * posterior.phis[i-1].c;

  const OperatorKLJ OpKLJ(k, theta.GetPrecisions(), J);

  SymmetricMatrix alphaPrecisions = prior.alpha.GetPrecisions();

  const int T = nAlphas; // use same code for nAlphas == 3 or 4

  { Tracer_Plus tr("Ar1cNoiseModel::UpdateAlpha - precision calculations");
  
  for (int i = 1; i <= nNoiseModels; i++)
  alphaPrecisions(i,i) += 
    si_ci(i) * OpKLJ(alphaMat.GetMatrix(i,2,0));
    
  if (T>2)
  { 
    // we have at least one cross-term
    alphaPrecisions(3,1) += // SymmetricMatrix, so this also sets (1,3)
        0.5 * si_ci(1) * OpKLJ(alphaMat.GetMatrix(1,1,1));
    alphaPrecisions(T,2) += // also sets (2,3)
        0.5 * si_ci(2) * OpKLJ(alphaMat.GetMatrix(2,1,1));
    alphaPrecisions(3,3) +=
        si_ci(1) * OpKLJ(alphaMat.GetMatrix(1,0,2));
    alphaPrecisions(T,T) +=
        si_ci(2) * OpKLJ(alphaMat.GetMatrix(2,0,2));
  }
  posterior.alpha.SetPrecisions(alphaPrecisions);

  // Check all finite and all variances are positive
  if (!(0*alphaPrecisions == 0*alphaPrecisions))
    throw overflow_error("Non-finite values in alpha precisions!");
  DiagonalMatrix checkVars(alphaPrecisions.Nrows());
  checkVars << alphaPrecisions.i();
  if (checkVars.Minimum() < 0)
    {
      OUT(alphaPrecisions.i());
      OUT(checkVars);
      throw overflow_error("Negative variance!");
    }

  } { Tracer_Plus tr("Ar1cNoiseModel::UpdateAlpha - mean calculations");
  ColumnVector tmp(T);
  tmp = prior.alpha.GetPrecisions() * prior.alpha.means;
  for (int i = 1; i <= nNoiseModels; i++)
    tmp(i) += -0.5 * si_ci(i) * OpKLJ(alphaMat.GetMatrix(i,1,0));

  if (T>2)
  {
    tmp(3) +=
        -0.5 * si_ci(1) * OpKLJ(alphaMat.GetMatrix(1,0,1));
    tmp(T) +=
        -0.5 * si_ci(2) * OpKLJ(alphaMat.GetMatrix(2,0,1));
  }
  posterior.alpha.means = posterior.alpha.GetCovariance() * tmp;
  }

  // Warn if any alphas are significantly larger than 1
  if (posterior.alpha.means.MaximumAbsoluteValue() > 1)
    {
      LOG << "Warning: alpha magnitude > 1... "
	   << "maybe right but probably bad" << endl;
      LOG << "Values: " << posterior.alpha.means.t();
      // throw overflow_exception("Alpha > 1 detected");
    }

  { Tracer_Plus tr("Ar1cNoiseModel::UpdateAlpha - alphaMat updates");
  // Update the alpha marginals (used by phi and theta updates)
  alphaMat.Update(posterior, data.Nrows()/nPhis);
  }
  
}


void Ar1cNoiseModel::UpdatePhi(
    NoiseParams& noise,
    const NoiseParams& noisePrior,
    const MVNDist& theta,
    const LinearFwdModel& linear,
    const ColumnVector& data) const
{
    Tracer_Plus tr("Ar1cNoiseModel::UpdatePhi");

    Ar1cParams& posterior = dynamic_cast<Ar1cParams&>(noise);
    const Ar1cParams& prior = dynamic_cast<const Ar1cParams&>(noisePrior);  
    Ar1cMatrixCache& alphaMat = posterior.alphaMat;    

    const Matrix& J = linear.Jacobian();
    ColumnVector k = data - linear.Offset() + J*(linear.Centre() - theta.means);
    int nTimes = data.Nrows() / nPhis; // Number of data points FOR EACH ECHO

    for (int i = 1; i <= nPhis; i++)
      {
        { Tracer_Plus tr("Ar1cNoiseModel::UpdatePhi - main calculations");
	const SymmetricBandMatrix &Qi = alphaMat.GetMarginal(i);

	double tmp = 
	  (k.t() * Qi * k).AsScalar() 
	  + (theta.GetCovariance() * J.t() * Qi * J).Trace();

	posterior.phis[i-1].b =
	  1/( tmp*0.5 + 1/prior.phis[i-1].b );
        }
      
        assert(posterior.phis[i-1].b > 0);

	posterior.phis[i-1].c =
	  (nTimes-1)*0.5 + prior.phis[i-1].c;
      }
      
}

void Ar1cNoiseModel::UpdateTheta(
    const NoiseParams& noise,
  	MVNDist& theta,
  	const MVNDist& thetaPrior,
  	const LinearFwdModel& linear,
        const ColumnVector& data,
    MVNDist* thetaWithoutPrior,
    float LMalpha
    ) const
{	
  Tracer_Plus tr("Ar1cNoiseModel::UpdateTheta");

  const Ar1cParams& posterior = dynamic_cast<const Ar1cParams&>(noise);
  const Ar1cMatrixCache& alphaMat = posterior.alphaMat;


    // Translated from vb_ar1c_update_theta in the NPINTS project in FMRIB's CVS.
    
    const ColumnVector &ml = linear.Centre();
    const ColumnVector &gml = linear.Offset();
    const Matrix &J = linear.Jacobian();
    
    ColumnVector si_ci(nPhis);
    for (int i = 1; i <= nPhis; i++)
        si_ci(i) = posterior.phis.at(i-1).b * posterior.phis.at(i-1).c;
    
    SymmetricBandMatrix X;
    { Tracer_Plus tr("Ar1cNoiseModel::UpdateTheta - X calculations");
    if (nPhis == 2)
        X = si_ci(1) * alphaMat.GetMarginal(1) + si_ci(2) * alphaMat.GetMarginal(2);
    else
        X = si_ci(1) * alphaMat.GetMarginal(1);
    }    

//    SymmetricMatrix Ltmp = J.t() * X * J;
    SymmetricMatrix Ltmp;
    { 
      Tracer_Plus tr("Ar1cNoiseModel::UpdateTheta - L calculations");
    
      Matrix Ltmp_tmp = J.t() * X * J;
      // LOG<<"Max error: "<<(Ltmp_tmp.t() - Ltmp_tmp).MaximumAbsoluteValue() 
      //    <<", compared to "<<Ltmp_tmp.MaximumAbsoluteValue()<<endl;
      // assert(Ltmp_tmp.t() == Ltmp_tmp);
      Ltmp << Ltmp_tmp;
      // assert(Ltmp == Ltmp_tmp);
    }

    ColumnVector mTmp;
    { 
      Tracer_Plus tr("Ar1cNoiseModel::UpdateTheta - m calculations");
      mTmp = J.t() * X * (data - gml + J*ml);
     
      theta.SetPrecisions(thetaPrior.GetPrecisions() + Ltmp);
      theta.means = theta.GetCovariance() 
	* ( mTmp + thetaPrior.GetPrecisions() * thetaPrior.means ); 
    }

    if (thetaWithoutPrior != NULL)
      {
	Tracer_Plus tr("Ar1cNoiseModel::UpdateTheta - WithoutPrior calcs");
	thetaWithoutPrior->SetSize(theta.GetSize());

	// Quick hack: prevent errors when thetaWithoutPrecisions is inverted
	bool wasSingular = false;
	for (int k = 1; k <= Ltmp.Nrows(); k++)
	  if (Ltmp(k,k) == 0) 
	    {
	      Ltmp(k,k) = 1e-20; 
	      wasSingular = true;
	    }
	
	if (wasSingular)
	  {
	    Warning::IssueOnce("Ltmp was singular, so changed zeros on diagonal to 1e-20.");
	    // cout << "Ltmp == \n" << Ltmp << "mTmp == \n" << mTmp;
	  }
	
	thetaWithoutPrior->SetPrecisions(Ltmp);
	thetaWithoutPrior->means = thetaWithoutPrior->GetCovariance() * mTmp;
      }

    {
      Tracer_Plus tr("Ar1cNoiseModel::UpdateTheta - Error checking");
      LogAndSign chk = theta.GetPrecisions().LogDeterminant();
      if (chk.Sign() <= 0)
	LOG 
	  <<"Note: In UpdateTheta, theta precisions aren't positive-definite: "
	  << chk.Sign() << ", " << chk.LogValue() << endl; 
    }
}


ostream& operator<<(ostream& s, vector<double> n)
{
  for (unsigned i = 0; i < n.size(); i++)
    s << n[i] << " ";
  return s;
}

double Ar1cNoiseModel::CalcFreeEnergy(
    const NoiseParams& noise,
    const NoiseParams& noisePrior,
	const MVNDist& theta,
  	const MVNDist& thetaPrior,
  	const LinearFwdModel& linear,
  	const ColumnVector& data) const
{
  Tracer_Plus tr("Ar1cNoiseModel::CalcFreeEnergy");

  const Ar1cParams& posterior = dynamic_cast<const Ar1cParams&>(noise);
  const Ar1cParams& prior = dynamic_cast<const Ar1cParams&>(noisePrior);  
  const Ar1cMatrixCache& alphaMat = posterior.alphaMat;


  const Matrix &J = linear.Jacobian();
  ColumnVector k = data - linear.Offset()
    + J * (linear.Centre() - theta.means);
  const SymmetricMatrix& Linv = theta.GetCovariance();

  const GammaDist &phi1 = posterior.phis.at(1-1);
  SymmetricMatrix Qsum;
  if (nPhis == 2)
  {
  const GammaDist &phi2 = posterior.phis.at(2-1);
  
  Qsum 
    = alphaMat.GetMarginal(1) * (phi1.b*phi1.c) 
    + alphaMat.GetMarginal(2) * (phi2.b*phi2.c);
  }
  else
  {
  Qsum 
    = alphaMat.GetMarginal(1) * (phi1.b*phi1.c); 
  }

  int nTimes = data.Nrows() / nPhis; // Number of data points FOR EACH ECHO
  int nTheta = theta.means.Nrows();
  int nAlphas = posterior.alpha.means.Nrows();
  
  // These equations have been directly translated from the MATLAB NPINTS code
  // in vb_ar1c_freeenergy.m, as of 12-Apr-2007. 

  double expectedLogAlphaDist = // Now match
    +0.5 * posterior.alpha.GetPrecisions().LogDeterminant().LogValue()
    -0.5 * nAlphas * (log(2*M_PI) + 1);

  double expectedLogThetaDist = // Now match
    +0.5 * theta.GetPrecisions().LogDeterminant().LogValue()
    -0.5 * nTheta * (log(2*M_PI) + 1);

  double expectedLogPhiDist = 0;
  vector<double> expectedLogPosteriorParts(10);
  for (int i = 0; i<10; i++) 
    expectedLogPosteriorParts[i] = 0;
  
  for (int i = 0; i < nPhis; i++) 
    {
      double si = posterior.phis[i].b;
      double ci = posterior.phis[i].c;
      double siPrior = prior.phis[i].b;
      double ciPrior = prior.phis[i].c;

      expectedLogPhiDist +=
	-gammaln(ci) - ci*log(si) - ci
	+(ci-1)*(digamma(ci)+log(si));
      
      expectedLogPosteriorParts[0] += 
	(digamma(ci)+log(si)) * ( (nTimes-1)*0.5 + prior.phis[i].c - 1 );
      
      expectedLogPosteriorParts[9] += 
	-2*gammaln(ciPrior) -2*ciPrior*log(siPrior) - si*ci/siPrior;
    }
  
  expectedLogPosteriorParts[1] =
    -log(2*M_PI)*(nTimes - 1 + 0.5*nAlphas + 0.5*nTheta);
  
  expectedLogPosteriorParts[2] =
    -0.5 * (k.t() * Qsum * k).AsScalar() 
    -0.5 * (J.t() * Qsum * J * Linv).Trace();
  
  expectedLogPosteriorParts[3] =
    +0.5 * thetaPrior.GetPrecisions().LogDeterminant().LogValue();
  
  expectedLogPosteriorParts[4] = 
    -0.5 * (
            (theta.means - thetaPrior.means).t() 
            * thetaPrior.GetPrecisions() 
            * (theta.means - thetaPrior.means)
	    ).AsScalar();
  
  expectedLogPosteriorParts[5] =
    -0.5 * (Linv * thetaPrior.GetPrecisions()).Trace();

  expectedLogPosteriorParts[6] =
    +0.5 * prior.alpha.GetPrecisions().LogDeterminant().LogValue();
  
  expectedLogPosteriorParts[7] = 
    -0.5 * (
            (posterior.alpha.means - prior.alpha.means).t()
            *prior.alpha.GetPrecisions()
            *(posterior.alpha.means - prior.alpha.means)
	    ).AsScalar();// */   
  
  expectedLogPosteriorParts[8] = 
    -0.5 * (posterior.alpha.GetCovariance() * prior.alpha.GetPrecisions()).Trace();
  
  // Assemble the parts into F
  double F = 
    - expectedLogAlphaDist 
    - expectedLogThetaDist 
    - expectedLogPhiDist;
  
  for (int i=0; i<10; i++) 
    F += expectedLogPosteriorParts[i];

  // Display the breakdown into terms
  /*  LOG << "F parts: " << -expectedLogAlphaDist << ", " 
       << -expectedLogThetaDist << ", " 
       << -expectedLogPhiDist;
  for (int i=0; i<10; i++) 
    LOG << ", [" << i << "] == " << expectedLogPosteriorParts[i]; 
  LOG << endl;
  // */
      
  // Error checking
  if (! (F - F == 0) )
  {
    LOG_ERR("expectedLogAlphaDist == " << expectedLogAlphaDist << endl);
    LOG_ERR("expectedLogThetaDist == " << expectedLogThetaDist << endl);
    LOG_ERR("expectedLogPhiDist == " << expectedLogPhiDist << endl);
    LOG_ERR("expectedLogPosteriorParts == " << expectedLogPosteriorParts << endl);
    throw overflow_error("Non-finite free energy!");
  }
  
  return F;
}

/*void Ar1cNoiseModel::Dump(const string indent) const
{
  LOG << indent << "AR(1)c noise model\n";

  DumpPrior(indent + "  ");  
  DumpPosterior(indent + "  "); 
}*/

/*void Ar1cNoiseModel::DumpPrior(const string indent) const
{
  if (prior) 
    {
      LOG << indent << "Prior distribution:\n";
      prior->Dump(indent + "  ");
    }
  else
    LOG << indent << "Prior distribution == NULL";
}*/

/*void Ar1cNoiseModel::DumpPosterior(const string indent) const
{
  if (posterior)
    {
      LOG << indent << "Posterior distribution:\n";
      posterior->Dump(indent + "  ");
    }
  else
    LOG << indent << "Posterior distribution == NULL";
}*/

void Ar1cParams::Dump(const string indent) const
{
	LOG << indent << "Alpha:" << endl;
    alpha.Dump(indent + "  ");
    for (unsigned int i = 0; i < phis.size(); i++) 
      {
        LOG << indent << "Phi_" << i+1 << ": ";
        phis[i].Dump();
      }
}

// Ar1cMatrixCache

void Ar1cMatrixCache::Update(const Ar1cParams& dist, int nTimes)
{
  Tracer_Plus tr("Ar1cMatrixCache::Update");

//  LOG << "In Ar1cMatrixCache::Update..." << endl;
  // Let's see if alphaMatrices have been defined yet
  if (alphaMatrices.size() == 0)
 {
    assert(alphaMarginals.size() == 0); // Marginals always calculated afterwards
  	alphaMatrices.resize(FlattenIndex(nPhis,0,2)+1);

	// This is horrible, I know, but it's late and I'm tired.
	for (int n = 1; n <= nPhis; n++)
	  {
	    for (int a12pow = 0; a12pow <= 2; a12pow++)
	      {
	        for (int a34pow = 0; a34pow <= 2-a12pow; a34pow++)	
	          {
                if (dist.alpha.means.Nrows() < 3 && a34pow > 0) 
                    break; // don't calculate unnecessary terms
                
 		        unsigned index = FlattenIndex(n, a12pow, a34pow);
                assert(index < alphaMatrices.size());
  		        SymmetricBandMatrix& mat = alphaMatrices[index]; 
  
      	        mat.ReSize(nTimes*nPhis, AR1_BANDWIDTH);
	            mat = 0;
      
                // Take advantage of the fact that all the alphaMatrices have the same
                //  form: a single diagonal line (sometimes reflected to keep the matrix
                //  symmetric) with length = nTimes-1.

                int row, col; double value;
                switch( a12pow*10 + a34pow )
	              {
	               // These are for the matlab style, where the data sets from the 
		       // two echo times are concatenated rather than interleaved:
	               //case 00: row = col = 2; break;
	               //case 10: row = 1; col = 2; break;
	               //case 20: row = col = 1; break;
	               //case 01: row = nTimes+2; col = 2; break;
	               //case 11: row = nTimes+2; col = 1; break;
	               //case 02: row = col = nTimes+2; break;
	               //default: assert(false);
	  
	               // For the interleaved TE1/TE2 style.
	               // 0<i<=nTimes: -> 2*i-1
	               // nTimes<i<=2*nTimes: -> 2*(i-nTimes)
	               // so 1->1, 2->3, nTimes+2->4
		      case 00: row = col = 1+nPhis; break;
		      case 10: row = 1; col = 1+nPhis; break;
		      case 20: row = col = 1; break;
		      case 01: row = 4; col = 3; break;
		      case 11: row = 4; col = 1; break;
		      case 02: row = col = 4; break;
		      default: assert(false);
	              }

                if (a12pow + a34pow == 1)
	               value = -1; 
                else
	               value = 1;

                // These assignments are for the phi1-related matrix; quadrants are 
                // swapped for phi2:
                //      if (n==2) 
                //	{
                //	  row = (row + nTimes) % (2*nTimes);
                //	  col = (col + nTimes) % (2*nTimes);
                //	}
                if (n==2)
	              {
	                row = row - 1 + 2*(row%2); // 2n->2n-1, 2n-1->2n
	                col = col - 1 + 2*(col%2);
	              }

                // for (int count = 0; count < nTimes-1; count++, row++, col++)
                for (int count = 0; count < nTimes-1; count++, row+=nPhis, col+=nPhis)    
	              {
                	// LOG << "row="<<row<<",col="<<col<<endl;
	                mat(row,col) = value;
		            assert(row<=mat.Nrows() && col<=mat.Ncols());
	              }
  	         }
  	     }
  	 }
  }

  // So now we know alphaMatrices are defined.
  assert (alphaMatrices[0].Nrows() == nTimes*nPhis);

  // Always update the alphaMatrices
  if (alphaMarginals.size() == 0)
    {
  	alphaMarginals.resize(2);
	alphaMarginals[0].ReSize(nTimes*nPhis, AR1_BANDWIDTH);
	alphaMarginals[1].ReSize(nTimes*nPhis, AR1_BANDWIDTH);
    }
  assert(alphaMarginals[0].Nrows() == nTimes*nPhis);
  assert(alphaMarginals[1].Nrows() == nTimes*nPhis);
  
  const unsigned nAlphas = dist.alpha.means.Nrows();
  
  for (int n=1; n<=nPhis; n++)
    {
      
      Matrix covarPlus = dist.alpha.GetCovariance()
        + dist.alpha.means * dist.alpha.means.t();
      assert(covarPlus == covarPlus.t());  // must by symmetric

//      LOG << "CovarPlus is\n" << covarPlus;

      if (nAlphas >= 3)
      {
        const int T = (nAlphas == 4) ? 2+n : 3;

        alphaMarginals.at(n-1) = GetMatrix(n, 0, 0)
            + GetMatrix(n, 1, 0) * dist.alpha.means(n)
            + GetMatrix(n, 2, 0) * covarPlus(n,n)
            + GetMatrix(n, 0, 1) * dist.alpha.means(T)
            + GetMatrix(n, 1, 1) * covarPlus(n,T)
            + GetMatrix(n, 0, 2) * covarPlus(T,T);
      } else {
        assert(nAlphas == 2);

        alphaMarginals.at(n-1) = GetMatrix(n, 0, 0)
            + GetMatrix(n, 1, 0) * dist.alpha.means(n)
            + GetMatrix(n, 2, 0) * covarPlus(n,n);
      }    
    }
  
}

const SymmetricBandMatrix& Ar1cMatrixCache::GetMatrix(unsigned n, unsigned a12pow, 
					unsigned a34pow) const
{ 
//  LOG << "Called: GetMatrix(" << n << "," << a12pow << "," << a34pow << ")" << endl;
  assert(alphaMatrices.size() > FlattenIndex(n, a12pow, a34pow));
  return alphaMatrices[FlattenIndex(n, a12pow, a34pow)]; //[n-1][a12pow][a3pow]; 
}

const SymmetricBandMatrix& Ar1cMatrixCache::GetMarginal(unsigned n) const
{ 
//  LOG << "In GetMarginal("<<n<<") const" << endl;
//  LOG << alphaMarginals.size() << ":" << alphaMarginals[n-1].Nrows()<<endl;
  if (alphaMarginals.size() < n)
    throw Logic_error(("GetMarginal(" + stringify(n)
		       + "): not enough elements (only" 
		       + stringify(alphaMarginals.size()) 
		       + ") in alphaMarginals!\n" ).c_str() );
  //  LOG << "Size of alphaMarginals[n-1] is " << alphaMarginals[n-1].Nrows() << " by " << alphaMarginals[n-1].Ncols() << endl;
  return alphaMarginals[n-1]; 
}

void Ar1cNoiseModel::Precalculate( NoiseParams& noise, const NoiseParams& noisePrior, 
    const ColumnVector& sampleData ) const
{ 
    Tracer_Plus tr("Ar1cMatrixCache::Precalculate");

    Ar1cParams& posterior = dynamic_cast<Ar1cParams&>(noise);
    const Ar1cParams& prior = dynamic_cast<const Ar1cParams&>(noisePrior);  
    Ar1cMatrixCache& alphaMat = posterior.alphaMat;
        
    int nTimes = sampleData.Nrows() / nPhis;
    
    // Pre-calculate the alpha matrices and alpha marginals
    // after this, the matrices should never change (marginals are updated)
    // by UpdateAlpha's call to alphaMat.Update().
    alphaMat.Update( posterior,  nTimes );
    
    // Prevents the massive (artificial) drop in F on the first phi update:
    // (needed so that F results match MATLAB exactly)
    for (int i=0; i<nPhis; i++) {
        posterior.phis.at(i).c = prior.phis.at(i).c + (nTimes-1) * 0.5;
    }
}

/*const MVNDist Ar1cNoiseModel::GetResultsAsMVN() const
{ 
  assert(posterior); 
  return posterior->alpha;
  // return MVNDist( posterior->alpha, posterior->phisAsMVN() );
}*/

const MVNDist Ar1cParams::OutputAsMVN() const
{
  MVNDist phiMVN( phis.size() );
  SymmetricMatrix phiVars( phis.size() );
  phiVars = 0; // off-diagonals are all zero
  for (unsigned i = 1; i <= phis.size(); i++)
  {
    phiMVN.means(i) = phis[i-1].CalcMean();
    phiVars(i,i) = phis[i-1].CalcVariance();
  }
  phiMVN.SetCovariance(phiVars);
  
  return MVNDist( alpha, phiMVN ); // concatenate the distributions
}

void Ar1cParams::InputFromMVN( const MVNDist& mvn )
{
    Tracer_Plus tr("Ar1cParams::InputFromMVN");
    // We must already know nAlpha & nPhi from the constructor!
    const unsigned nAlpha = alpha.means.Nrows();
    assert( nAlpha + phis.size() == (unsigned)mvn.GetSize() );
    alpha.CopyFromSubmatrix(mvn, 1, nAlpha, true);
    for (unsigned i = 1; i <= phis.size(); i++)
    {
        phis[i-1].SetMeanVariance( mvn.means(nAlpha+i), 
            mvn.GetCovariance()(nAlpha+i,nAlpha+i) );
        for (unsigned j = i+1; j <= phis.size(); j++)
            if (mvn.GetCovariance()(nAlpha+i, nAlpha+j) != 0.0)
                throw Invalid_option("Phis should have zero covariance!");
    }    
} 