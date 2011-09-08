import java.util.ArrayList;
import java.util.Random;
import java.util.Timer;

class Timing {
	public static void main(String[] args) {
		//timeStaticArray();
		timeDynamicArray();
	}

	public static void timeDynamicArray() {
		long start;
		long end;
		long startloop;
		long endloop;
		final int SIZE = 1000;
		long pos;
		Runtime r = Runtime.getRuntime();
		ArrayList<Integer> dynarr = new ArrayList<Integer>();
		ArrayList<Integer> tmp = new ArrayList<Integer>();

		long loop = timeLoop(SIZE);

		for(int offs = 1; offs < 10; offs++) {
			pos = System.nanoTime();
			for(int i = 0; System.nanoTime() < 1000000000L+pos; i++) {
				if(i >= 100000) {
					dynarr = new ArrayList<Integer>();
					//r.gc();
				}
				dynarr.add(6);
			}

			dynarr = new ArrayList<Integer>();

			start = System.nanoTime();
			for(int i = 0; i < SIZE*offs; i++) {
				dynarr.add(6);
			}
			end = System.nanoTime();
			long average = end - start;
			System.out.println((SIZE*offs) + "\t" + average + "\t" + (average/(SIZE*offs)));
		}
	}


	public static void timeStaticArray() {
		long start;
		long end;
		long startloop;
		long endloop;
		final int SIZE = 1000;
		Integer[] staticarr = new Integer[100000];
		Integer[] tmp;

		for(int i = 0; i < 2000000000; i++) {
			staticarr[i % staticarr.length] = 6;
		}

		startloop = System.nanoTime();
		for(int i = 0; i < SIZE; i++) {
		}
		endloop = System.nanoTime();
		long loop = endloop - startloop;
		System.out.println(loop);

		for(int offs = 1; offs < 20; offs++) {
			for(int i = 0; i < 1000000000L; i++) {
				staticarr[i % staticarr.length] = 6;
			}

			start = System.nanoTime();
			for(int i = 0; i < SIZE*offs; i++) {
				staticarr[i % staticarr.length] = 6;
			}
			end = System.nanoTime();
			long average = end - start;
			System.out.println((SIZE*offs) + "\t" + average + "\t" + average/(SIZE*offs));
		}
	}

	public static long timeLoop(long numOfOps) {
		int[] tmp = new int[100000];
		long start;
		long end;

		for(int i = 0; i < 2000000000; i++) {
			tmp[i % tmp.length] = 6;
		}

		start = System.nanoTime();
		for(int i = 0; i < numOfOps; i++) {
		}
		end = System.nanoTime();
		long loop = end - start;
		return loop;
	}
}
