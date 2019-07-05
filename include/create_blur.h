#ifndef CREATE_DFD_BLUR_H_
#define CREATE_DFD_BLUR_H_

#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <string>

#include <opencv2/core/core.hpp>           
#include <opencv2/highgui/highgui.hpp>     
#include <opencv2/imgproc/imgproc.hpp>  

using namespace std;

int createGaussKernel(int size, double sigma, cv::Mat &kernel)
{
	// assumes a 0 mean Gaussian distribution
	int row, col;
    double s = sigma*sigma;

    kernel = cv::Mat::zeros(size, size, CV_64FC1);


	for (row = 0; row < size; ++row)
	{
		for (col = 0; col < size; ++col)
		{
			kernel.at<double>(row, col) = (1.0 / (2 * CV_PI *s)) * std::exp((-((col - (size >> 1))*(col - (size >> 1))) - ((row - (size >> 1))*(row - (size >> 1)))) / (2 * s));
		}
	}

	double matsum = (double)cv::sum(kernel)[0];

	kernel = kernel * (1.0 / matsum);	// get the matrix to sum up to 1...

	return 1;

}	// end of createGaussKernel


void createblur(cv::Mat ImageInFocus, double maxSigma, double minSigma, int classes, vector<cv::Mat> &xt)
{
	int idx;
	double BlurStep, sigma;
    //double sigma_step;

	// Create Multi-level blur image 
	BlurStep = maxSigma / (double)classes;

    int size = 27;
	cv::Size kernelSize = cv::Size(size, size);
	cv::Mat gaussKernel;
	//cv::Mat prevKernel = cv::Mat::zeros(size, size, CV_64FC1);


    if (minSigma == 0.0)
        sigma = BlurStep;
    else
        sigma = minSigma;

    // normal gaussian kernel creation
	for (idx = 0; idx < classes; ++idx)
	{
		cv::Mat tempBlur;

        //sigma_step = BlurStep * (idx + 1);
        // standard - linear step 
		//sigma = sigma_step;   // BlurStep * (idx + 1);

        // test sigmas
        //sigma = maxSigma * std::pow((idx+1)/(double)classes, 0.3);
        //sigma = (maxSigma * 2 * sig_step) / (double)(1 + 2 * std::abs(sig_step));

		createGaussKernel(size, sigma, gaussKernel);

		cv::filter2D(ImageInFocus, tempBlur, CV_64FC1, gaussKernel, cv::Point(-1, -1), 0.0, cv::BorderTypes::BORDER_REPLICATE);

		// push results back into vecor
		xt.push_back(tempBlur);

        sigma += BlurStep;

	}

/*
    // test to see if we can replicate photoshop lens blur effect
    for (idx = 0; idx < classes; ++idx)
    {
        cv::Mat tempBlur;

        createGaussKernel(size, maxSigma, gaussKernel);

        gaussKernel = (double)((idx+1)*0.001)*gaussKernel;
        cv::filter2D(ImageInFocus, tempBlur, CV_64FC1, gaussKernel, cv::Point(-1, -1), 0.0, cv::BorderTypes::BORDER_REPLICATE);

        // push results back into vecor
        xt.push_back(tempBlur);

        //sigma += BlurStep;

    }

*/



}	// end of createblur

#endif  // CREATE_DFD_BLUR_H_


