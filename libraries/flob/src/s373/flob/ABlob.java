/**
 * Flob
 * Fast multi-blob detector and simple skeleton tracker using flood-fill algorithms.
 * http://s373.net/code/flob
 *
 * Copyright (C) 2008-2013 Andre Sier http://s373.net
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 */
package s373.flob;

/**
 * ABlob extends baseBlob data struct.
 * 
 * ABlob holds info and normalized info for a simple blob.
 * now also has raw integer vel calculations (not tracked blob,
 * so not reliable, but fast).
 * 
 */
public class ABlob extends baseBlob {
	public int boxdimx, boxdimy;
	public int pboxcenterx, pboxcentery;
	public int ivelx,ively;
	// world values
	public float cx, cy;
	public float bx, by;
	public float dimx, dimy;

	/// features:
	public float armleftx, armlefty, armrightx, armrighty, headx, heady,
			bottomx, bottomy, footleftx, footlefty, footrightx, footrighty;


	public ABlob() {
		boxdimx = boxdimy = ivelx = ively = 0;
		cx = cy = bx = by = dimx = dimy = 0.0f;
		pboxcenterx = pboxcentery= -1;
	}

	public ABlob(ABlob b) {
		id = b.id;
		pixelcount = b.pixelcount;
		boxminx = b.boxminx;
		boxminy = b.boxminy;
		boxmaxx = b.boxmaxx;
		boxmaxy = b.boxmaxy;
		boxcenterx = b.boxcenterx;
		boxcentery = b.boxcentery;
		boxdimx = b.boxdimx;
		boxdimy = b.boxdimy;
		if(b.pboxcenterx==-1){
			pboxcenterx = boxcenterx;
			pboxcentery = boxcentery;
		} else {
			pboxcenterx = b.pboxcenterx;
			pboxcentery = b.pboxcentery;
		}
		ivelx = boxcenterx - pboxcenterx;
		ively = boxcentery - pboxcentery;

		cx = b.cx;
		cy = b.cy;
		bx = b.bx;
		by = b.by;
		dimx = b.dimx;
		dimy = b.dimy;

		armleftx = b.armleftx;
		armlefty = b.armlefty;
		armrightx = b.armrightx;
		armrighty = b.armrighty;
		headx = b.headx;
		heady = b.heady;
		bottomx = b.bottomx;
		bottomy = b.bottomy;
		footleftx = b.footleftx;
		footlefty = b.footlefty;
		footrightx = b.footrightx;
		footrighty = b.footrighty;
	}
}
