// Written by Joe Zachary for CS 4150, February 2010.


import java.math.*;
import java.util.*;


// Provides methods for studying the tradeoffs between grade school and
// Karatsuba multiplication.

public class Multiply {

	// Used to generate test data
	private static Random random = new Random();

	// Cutover point for blended algorithm
	private static int cutover;



	// Gathers command line parameters and conducts tests.  

	public static void main (String[] args) {

		// Usage information
		if (args.length < 2) {
			System.err.println("Usage: java Multiply [mkbs] <bits> <cutover>");
			return;
		}

		// Parse command line arguments
		char algorithm = args[0].charAt(0);
		int bitLength = Integer.parseInt(args[1]);
		if (algorithm == 'b') {
			cutover = Integer.parseInt(args[2]);
		}
		
		doTiming(algorithm, bitLength);
		
	}
	
	
	public static void doTiming (char algorithm, int bitLength) {

		
		// Figure out the overhead of the timing loop
		int overheadRepts = 1;
		long overheadTime = 0;

		while (overheadTime < 1000000000) {
			
			// Keep increasing repetitions until the loop takes one second
			overheadRepts *= 2;

			// Time the overhead
			long start = System.nanoTime();
			
			for (int i = 0; i < overheadRepts; i++) {

				BigInteger x = makeNumber(bitLength);
				BigInteger y = makeNumber(bitLength);

				switch (algorithm) {
				case 'm':
					dummy(x,y);
					break;
				case 'k':
					dummy(x,y);
					break;
				case 'b':
					dummy(x, y);
					break;
				default:

				}
			}
			
			long stop = System.nanoTime();
			overheadTime = stop - start;

		}
		
		
		// Time the overhead plus the computation time
		int overallRepts = 1;
		long overallTime = 0;
		
		while (overallTime < 1000000000) {
			
			// Keep increasing repetitions until the loop takes a second
			overallRepts *= 2;

			// Get the overall time
			long start = System.nanoTime();

			for (int i = 0; i < overallRepts; i++) {

				BigInteger x = makeNumber(bitLength);
				BigInteger y = makeNumber(bitLength);

				switch (algorithm) {
				case 'm':
					x.multiply(y);
					break;
				case 'k':
					karatsuba(x, y);
					break;
				case 'b':
					blended(x, y);
					break;
				default:

				}
			}
			
			long stop = System.nanoTime();
			overallTime = stop - start;
			
		}
		
		// Calculate the average and display results

		double timePerMultiplication = 
			overallTime/(1.0*overallRepts) - overheadTime/(1.0*overheadRepts);
		
		System.out.println(timePerMultiplication / 1e6 + " msec");

	}


	// Returns a randomly-generated positive integer with the specified number of bits.

	public static BigInteger makeNumber (int bits) {
		while (true) {
			BigInteger n = new BigInteger(bits, random);
			if (n.bitLength() == bits) return n;
		}
	}


	// Do-nothing function
	
	public static BigInteger dummy (BigInteger a, BigInteger b) {
		return a;
	}
	

	// Multiplies a and b using pure Karatsuba

	public static BigInteger karatsuba (BigInteger a, BigInteger b) {

		// Get length in bits of the two operands
		int aBits = a.bitLength();
		int bBits = b.bitLength();

		// Deal with the base cases
		if (aBits == 0 || bBits == 0) return BigInteger.ZERO;
		if (aBits == 1) return b;
		if (bBits == 1) return a;

		// Split the numbers into two parts
		int n = Math.max(aBits, bBits);
		BigInteger aHigh = a.shiftRight(n/2);
		BigInteger aLow = a.xor(aHigh.shiftLeft(n/2));
		BigInteger bHigh = b.shiftRight(n/2);
		BigInteger bLow = b.xor(bHigh.shiftLeft(n/2));

		// Do the three multiplications
		BigInteger p1 = karatsuba(aHigh, bHigh);
		BigInteger p2 = karatsuba(aHigh.add(aLow), bHigh.add(bLow));
		BigInteger p3 = karatsuba(aLow, bLow);

		// Shift the products to obtain three pieces
		BigInteger s1 = p1.shiftLeft(2*(n/2));
		BigInteger s2 = p2.subtract(p1).subtract(p3).shiftLeft(n/2);
		BigInteger s3 = p3;

		// Return the sum of the pieces
		return s1.add(s2).add(s3);

	}



	// Multiplies a and b using blended Karatsuba

	public static BigInteger blended (BigInteger a, BigInteger b) {

		// Get length in bits of the two operands
		int aBits = a.bitLength();
		int bBits = b.bitLength();

		// Cutover to regular multiplication for small numbers
		if (aBits <= cutover && bBits <= cutover) {
			return a.multiply(b);
		}

		// Split the numbers into two parts
		int n = Math.max(aBits, bBits);
		BigInteger aHigh = a.shiftRight(n/2);
		BigInteger aLow = a.xor(aHigh.shiftLeft(n/2));
		BigInteger bHigh = b.shiftRight(n/2);
		BigInteger bLow = b.xor(bHigh.shiftLeft(n/2));

		// Do the three multiplications
		BigInteger p1 = blended(aHigh, bHigh);
		BigInteger p2 = blended(aHigh.add(aLow), bHigh.add(bLow));
		BigInteger p3 = blended(aLow, bLow);

		// Shift the products to obtain three pieces
		BigInteger s1 = p1.shiftLeft(2*(n/2));
		BigInteger s2 = p2.subtract(p1).subtract(p3).shiftLeft(n/2);
		BigInteger s3 = p3;

		// Return the sum of the pieces
		return s1.add(s2).add(s3);

	}

}
