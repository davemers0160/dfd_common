#ifndef EVAL_DFD_NET_PERFORMANCE
#define EVAL_DFD_NET_PERFORMANCE

#include <cmath>
#include <cstdlib>
#include <cstdint>
#include <iostream>
#include <thread>
#include <vector>
#include <algorithm>
#include <string>

// Custom Includes
#include "ssim.h"
#include "center_cropper.h"
#include "dlib_matrix_threshold.h"
#include "calc_silog_error.h"

// dlib includes
#include <dlib/dnn.h>
#include <dlib/matrix.h>
#include <dlib/image_io.h>
#include <dlib/data_io.h>
#include <dlib/image_transforms.h>

template <typename net_type>
dlib::matrix<double, 1, 4> eval_net_performance(
    net_type &net,
    std::array<dlib::matrix<uint16_t>, img_depth> td,
    dlib::matrix<uint16_t> gt,
    dlib::matrix<uint16_t> &map,
    std::pair<uint64_t, uint64_t> crop_size
)
{
    double ssim_val = 0.0;
    double rmse_val = 0.0;
    double mae_val = 0.0;
    double silog_val = 0.0;

    uint16_t gt_min = 0, gt_max = 255;

    dlib::find_min_and_max(gt, gt_min, gt_max);

    // need to add the cyclic cropper part to make sure that the gpu doesn't crap out on large images
    map = net(td);

    // test of the get pixel error
    //dlib::matrix<double, 1, 4> px_err = get_pixel_error(gt, map);

    // calculate the scale invariant log error 
    silog_val = calc_silog_error(gt, map);

    // subtract the two maps
    dlib::matrix<float> sub_map = dlib::matrix_cast<float>(map) - dlib::matrix_cast<float>(gt);

    double m1 = dlib::mean(dlib::abs(sub_map));
    double m2 = dlib::mean(dlib::squared(sub_map));

    //double var = dlib::variance(gt[idx]);
    double rng = (double)std::max(gt_max - gt_min, 1);

    mae_val = m1 / rng;
    rmse_val = std::sqrt(m2) / rng;

    dlib::matrix<float> ssim_map;
    ssim_val = ssim(map, gt, ssim_map);

    dlib::matrix<double, 1, 4> res = dlib::zeros_matrix<double>(1, 4);
    res = mae_val, rmse_val, ssim_val, silog_val;

    return res;

}   // end of eval_net_performance

//-----------------------------------------------------------------------------

template <typename net_type>
dlib::matrix<double, 1, 4> eval_all_net_performance(
    net_type &net,
    std::vector<std::array<dlib::matrix<uint16_t>, img_depth>> &td,
    std::vector<dlib::matrix<uint16_t>> &gt,
    std::pair<uint64_t, uint64_t> crop_size
)
{
    uint32_t idx;
    DLIB_CASSERT(td.size() == gt.size());
    dlib::matrix<uint16_t> map;
    dlib::matrix<double, 1, 4> results = dlib::zeros_matrix<double>(1, 4);

    for (idx = 0; idx < td.size(); ++idx)
    {
        results += eval_net_performance(net, td[idx], gt[idx], map, crop_size);
    }

    return (results / (double)td.size());

} //end of eval_all_net_performance


#endif  //EVAL_DFD_NET_PERFORMANCE

