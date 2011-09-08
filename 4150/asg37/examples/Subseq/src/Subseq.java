// Solutions to longest subsequence problem

import java.util.*;

// Four different ways of calculating the longest increasing 
// subsequence

public class Subseq {
	
	public static void main (String[] args) {
		//A = new int[]{7, 2, 1, 6, 4, 5, 8};
		A = generateRandomArray(10);
		A = generateRandomArray(10033);
		//System.out.println(toString(A));
		System.out.println(longestSubseq5());
		//System.out.println(toString(longestSubseq6()));
	}
	
	
	// The array containing the sequence
	private static int[] A ;
	
	
	// Returns the length of the longest increasing subsequence
	// that ends at n.  Direct recursive implementation.
	public static int longestSubseq1 (int n) {
		int longest = 0;
		for (int i = 0; i < n; i++) {
			if (A[n] > A[i]) {
				int length = longestSubseq1(i);
				if (length > longest) {
					longest = length;
				}
			}
		}
		return longest+1;
	}
	
	
	
	// Returns the longest increasing subsequence that ends at n.
	// Direct recursive implementation.
	public static ArrayList<Integer> longestSubseq2 (int n) {
		ArrayList<Integer> longest = new ArrayList<Integer>();
		for (int i = 0; i < n; i++) {
			if (A[n] > A[i]) {
				ArrayList<Integer> subseq = longestSubseq2(i);
				if (subseq.size() > longest.size()) {
					longest = new ArrayList<Integer>(subseq);
				}
			}
		}
		longest.add(A[n]);
		return longest;
	}
	
		
	
	// Used for storing solutions to subproblems
	private static HashMap<Integer, ArrayList<Integer>> cache =
		new HashMap<Integer, ArrayList<Integer>>();
	
	
	// Returns the longest increasing subsequence that ends at n.
	// Memoized version.
	public static ArrayList<Integer> longestSubseq3 (int n) {
		if (cache.get(n) != null) {
			return cache.get(n);
		}
		ArrayList<Integer> longest = new ArrayList<Integer>();
		for (int i = 0; i < n; i++) {
			if (A[n] > A[i]) {
				ArrayList<Integer> subseq = longestSubseq3(i);
				if (subseq.size() > longest.size()) {
					longest = subseq;
				}
			}
		}
		longest = new ArrayList<Integer>(longest);
		longest.add(A[n]);
		cache.put(n, longest);
		return longest;
	}
	
	
	// Returns the longest increasing subsequence
	public static ArrayList<Integer> longestSubseq3 () {
		ArrayList<Integer> longest = new ArrayList<Integer>();
		for (int i = 0; i < A.length; i++) {
			ArrayList<Integer> subseq = longestSubseq3(i);
			if (subseq.size() > longest.size()) {
				longest = subseq;
			}
		}
		return longest;
	}
	
	
	
	// Returns the longest increasing subsequence that ends at k.
	// This version systematically fills out a table
	public static ArrayList<Integer> longestSubseq4 (int k) {
		for (int n = 0; n <= k; n++) {
			ArrayList<Integer> longest = new ArrayList<Integer>();
			for (int i = 0; i < n; i++) {
				if (A[n] > A[i]) {
					ArrayList<Integer> subseq = cache.get(i);
					if (subseq.size() > longest.size()) {
						longest = subseq;
					}
				}
			}
			longest = new ArrayList<Integer>(longest);
			longest.add(A[n]);
			cache.put(n, longest);
		}
		return cache.get(k);
	}
	
	
	
	
	// Returns the longest increasing subsequence in the array
	// This version fills out a table
	public static List<Integer> longestSubseq5 () {
		
		// length[i] is the length of the longest subsequence ending
		//   at index i
		// prev[i] is the index of the previous element in the longest
		//   subsequence ending at index i
		HashMap<Integer,Integer> length = new HashMap<Integer,Integer>();
		HashMap<Integer,Integer> prev = new HashMap<Integer,Integer>();
		
		// Fill in the hash tables	
		for (int n = 0; n < A.length; n++) {
			int longest = 0;
			int longestIndex = -1;
			for (int i = 0; i < n; i++) {
				if (A[n] > A[i]) {
					int size = length.get(i);
					if (size > longest) {
						longest = size;
						longestIndex = i;
					}
				}
			}
			length.put(n, longest+1);
			prev.put(n, longestIndex);
		}
		
		//System.out.println(length);
		//System.out.println(prev);
		
		
		// Next find the index where the longest subsequence ends.
		int longestIndex = 0;
		for (int n = 0; n < A.length; n++) {
			if (length.get(n) > length.get(longestIndex)) {
				longestIndex = n;
			}
		}
		
		// Next work backwards to reconstruct the sequence
		LinkedList<Integer> result = new LinkedList<Integer>();
		while (longestIndex >= 0) {
			result.addFirst(A[longestIndex]);
			longestIndex = prev.get(longestIndex);
		}
		
		// And return the result.
		return result;
		
	}
	
	
	// Returns the longest increasing subsequence in the array
	// This version uses arrays instead of hash maps.
	public static int[] longestSubseq6 () {
		
		// length[i] is the length of the longest subsequence ending
		//   at index i
		// prev[i] is the index of the previous element in the longest
		//   subsequence ending at index i
		int[] length = new int[A.length];
		int[] prev = new int[A.length];
		
		// Fill in the arrays	
		for (int n = 0; n < A.length; n++) {
			int longest = 0;
			int longestIndex = -1;
			for (int i = 0; i < n; i++) {
				if (A[n] > A[i]) {
					int size = length[i];
					if (size > longest) {
						longest = size;
						longestIndex = i;
					}
				}
			}
			length[n] = longest+1;
			prev[n] = longestIndex;
		}
		
		// Next find the index where the longest subsequence ends.
		int longestIndex = 0;
		for (int n = 0; n < A.length; n++) {
			if (length[n] > length[longestIndex]) {
				longestIndex = n;
			}
		}
		
		// Next work backwards to reconstruct the sequence
		int[] result = new int[length[longestIndex]];
		for (int i = result.length-1; i >= 0; i--) {
			result[i] = A[longestIndex];
			longestIndex = prev[longestIndex];
		}
		
		// And return the result.
		return result;
		
	}
		
	
	
	public static int[] generateArray (int n) {
		int[] A = new int[n];
		for (int i = 0; i < n; i++) {
			A[i] = i;
		}
		return A;
	}
	
	public static int[] generateRandomArray (int n) {
		int[] A = new int[n];
		Random rand = new Random();
		for (int i = 0; i < n; i++) {	
			A[i] = rand.nextInt(1000);
		}
		return A;
	}
	
	public static String toString (int[] A) {
		String s = "[";
		if (A.length > 0) {
			s += A[0];
		}
		for (int i = 1; i < A.length; i++) {
			s += ", " + A[i];
		}
		return s + "]";
	}
}
