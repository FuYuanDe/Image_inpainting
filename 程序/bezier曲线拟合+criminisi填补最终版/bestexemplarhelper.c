/**
 * A best exemplar finder.  Scans over the entire image (using a
sliding window) and finds the exemplar which minimizes the sum
 * squared error (SSE) over the to-be-filled pixels in the target patch. 
 *һ����ѷ�����ɨ������ͼ��(ʹ�û�������),������Сƽ�����֮�͵ķ���(SSE)��Ҫ�������Ŀ�겹����
 * @author Sooraj Bhat
 */
#include "mex.h"
#include <limits.h>

void bestexemplarhelper(const int mm, const int nn, const int m, const int n,    /*�����ӳ���*/
			const double *img, const double *Ip, 
			const mxLogical *toFill, const mxLogical *sourceRegion,
			double *best)   /*best�����������mm,nn,m,n,img,Ip,toFill,sourceRegion���������*/
{
  register int i,j,ii,jj,ii2,jj2,M,N,I,J,ndx,ndx2,mn=m*n,mmnn=mm*nn;
  double patchErr=0.0,err=0.0,bestErr=1000000000.0;

  /* foreach patch */
  N=nn-n+1;  M=mm-m+1;
  for (j=1; j<=N; ++j) {
    J=j+n-1;
    for (i=1; i<=M; ++i) {
      I=i+m-1;
      /*** Calculate patch error���㲹������***/
      /* foreach pixel in the current patchÿһ�������ڵ�ǰ�Ĳ��� */
      for (jj=j,jj2=1; jj<=J; ++jj,++jj2) {
	for (ii=i,ii2=1; ii<=I; ++ii,++ii2) {
	  ndx=ii-1+mm*(jj-1);
	  if (!sourceRegion[ndx])
	    goto skipPatch;
	  ndx2=ii2-1+m*(jj2-1);
	  if (!toFill[ndx2]) {
	    err=img[ndx      ] - Ip[ndx2    ]; patchErr += err*err;
	    err=img[ndx+=mmnn] - Ip[ndx2+=mn]; patchErr += err*err;
	    err=img[ndx+=mmnn] - Ip[ndx2+=mn]; patchErr += err*err;
	  }
	}
      }
      /*** UpdateУ��***/
      if (patchErr < bestErr) {
	bestErr = patchErr; 
	best[0] = i; best[1] = I;
	best[2] = j; best[3] = J;
      }
      /*** Reset���� ***/
    skipPatch:
      patchErr = 0.0; 
    }
  }
}

/* best = bestexemplarhelper(mm,nn,m,n,img,Ip,toFill,sourceRegion); ��ѷ�������*/
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])    /*����ӳ���,
                                                                              nlhs��ʾ��������ĸ���
                                                                              ����ΪmxArray��ָ������plhs[]������ָ�������ÿ������
                                                                              nrhs��ʾ��������ĸ���
                                                                              ����ΪmxArray��ָ������prhs[]������ָ�������ÿ������
                                                                              */
{
  int mm,nn,m,n;
  double *img,*Ip,*best;
  mxLogical *toFill,*sourceRegion; /*���庯�����������*/

  /* Extract the inputs��ȡ���� */
  mm = (int)mxGetScalar(prhs[0]);
  nn = (int)mxGetScalar(prhs[1]);
  m  = (int)mxGetScalar(prhs[2]);
  n  = (int)mxGetScalar(prhs[3]);
  img = mxGetPr(prhs[4]);
  Ip  = mxGetPr(prhs[5]);
  toFill = mxGetLogicals(prhs[6]);
  sourceRegion = mxGetLogicals(prhs[7]);
  
  /* Setup the output������� */
  plhs[0] = mxCreateDoubleMatrix(4,1,mxREAL);  /*����2ά˫���ȸ�����󣬿�����ʵ��(mxREAL)���߸���(mxCOMPLEX)*/
  best = mxGetPr(plhs[0]);
  best[0]=best[1]=best[2]=best[3]=0.0;

  /* Do the actual work��ʵ�ʵĹ��� */
  bestexemplarhelper(mm,nn,m,n,img,Ip,toFill,sourceRegion,best);
}
