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
		Runtime r = Runtime.getRuntime();
		ArrayList<Integer> dynarr = new ArrayList<Integer>();
		ArrayList<Integer> tmp = new ArrayList<Integer>();

		long loop = timeLoop(100);

		for(int offs = 1; offs < 10; offs++) {
			long go = System.nanoTime();
			dynarr.add(1);
			for(int i = 0; System.nanoTime() < 5000000000L+go; i++) {
				dynarr.get(0);
			}

			start = System.nanoTime();
			for(int i = 0; i < 100*offs; i++) {
				dynarr.add(6);
			}
			end = System.nanoTime();

			System.out.println(100*offs + "\t" + (end - start - (loop*offs)) + "\t" + ((end-start - (loop*offs)))/(100.0*offs));
		}
	}


	public static void timeStaticArray() {
		long start;
		long end;
		long startloop;
		long endloop;
		Integer[] staticarr = new Integer[100000];
		Integer[] tmp;

		for(int i = 0; i < 2000000000; i++) {
			staticarr[i % staticarr.length] = 6;
		}

		startloop = System.nanoTime();
		for(int i = 0; i < 10000000; i++) {
		}
		endloop = System.nanoTime();
		long loop = endloop - startloop;

		for(int offs = 1; offs < 10; offs++) {
			for(int i = 0; i < 2000000000; i++) {
				staticarr[i % staticarr.length] = 6;
			}

			start = System.nanoTime();
			for(int i = 0; i < 10000000*offs; i++) {
				staticarr[i % staticarr.length] = 6;
			}
			end = System.nanoTime();

			System.out.println(10000000*offs + "\t" + (end - start - (loop*offs)) + "\t" + ((end-start - (loop*offs)))/(10000000.0*offs));
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
