// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import './SDF.sol';
import '../core/Vectors.sol';
import '../lib/Conversion.sol';

library Layout {
    /**
    @notice Creates an NxM grid of rectangles w/ parametric spacing
    *  centered.
     */
    function gridRect(int rows, int cols, int w, int h, int[2]memory spacing, string memory rotation, int round) public pure  returns (string [] memory) {
        string[] memory rects  = new string[](uint(rows*cols));
        int x = -(w+spacing[0])*cols/2 + w;
        int y = -(h+spacing[1])*rows/2 + h;
        //int alt = altOffset ? w/2 : int(0);
        
        for (int i=0; i < rows; i++) {
            for (int j=0; j < cols; j++) {
                rects[uint(i*cols + j)] =  _rect(
                    uint(i*cols + j), 
                    x  + i*(w+spacing[0]),
                    y + (i % 2)*h + j*(h+spacing[1]),
                    w,
                    h,
                    rotation,
                    round
                    );
            }
        }
        return rects;
    }

    function gridRect(int rows, int cols, int w, int h, int spacing, int[] memory widths, int[] memory heights) public pure returns (string [] memory) {
        string[] memory rects  = new string[](uint(rows*cols));
        int x = -(w+spacing)*cols/2 + w;
        int y = -(h+spacing)*rows/2 + h;
        for (int i=0; i < rows; i++) {
            for (int j=0; j < cols; j++) {
                uint idx = uint(i*cols + j);
                rects[idx] = _rect(
                    idx, 
                    x + i*(w+spacing),
                    y + j*(h+spacing),
                    widths,
                    heights,
                    0
                    );
            }
        }
        return rects;
    }

    function _rect(uint idx, int x, int y, int[] memory widths, int [] memory heights, int rotation) public pure returns (string memory) {
        return SDF.rect(
            Vectors.vec2(
                x, y
            ),
            Vectors.vec2(widths[idx%widths.length], heights[idx%heights.length]),
            "vec4(.1, .1, .1, .1)",
            Conversion.int2float(rotation)
            ) ;
    }

    function _rect(uint idx, int x, int y, int w, int h, string memory rotation, int r)  public pure returns (string memory) {
        return SDF.rect(
            Vectors.vec2(
                x, y
            ),
            Vectors.vec2(w, h),
            Vectors.vec4(r, r, r, r),
            rotation
            ) ;
    }
}