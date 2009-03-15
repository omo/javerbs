

import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import org.apache.bcel.classfile.Method;
import org.apache.bcel.classfile.ClassParser;
import org.apache.bcel.classfile.JavaClass;
import org.apache.bcel.generic.ConstantPoolGen;
import org.apache.bcel.generic.Instruction;
import org.apache.bcel.generic.InstructionList;
import org.apache.bcel.generic.InvokeInstruction;
import org.apache.bcel.generic.MethodGen;

public class Main {
	
	public static void main(String[] args) throws IOException {
		for (String fname : args) {
			//dumpInvokedMethodNames(fname);
			dumpDefinedMethodNames(fname);
		}
	}

	@SuppressWarnings("unchecked")
	public static void dumpInvokedMethodNames(String filename) throws IOException {
		ZipFile zip = new ZipFile(filename);
		
		int n = 0;
		for (Enumeration<ZipEntry> ee = (Enumeration<ZipEntry>) zip.entries(); ee.hasMoreElements();) {
			ZipEntry e = ee.nextElement();
			InputStream ein = zip.getInputStream(e);
			if (e.getName().endsWith(".class")) {
				//System.out.println(e.getName());
				ClassParser parser = new ClassParser(ein, e.getName());
				JavaClass klass = parser.parse();
				ConstantPoolGen cpgen = new ConstantPoolGen(klass.getConstantPool());
				for (Method m : klass.getMethods()) {
					MethodGen mg = new MethodGen(m, klass.getClassName(), cpgen);
					InstructionList ilist = mg.getInstructionList();
					if (null != ilist) {
						for (Instruction ins : ilist.getInstructions()) {
							if (ins instanceof InvokeInstruction) {
								InvokeInstruction iins = (InvokeInstruction)ins;
								System.out.println(iins.getMethodName(cpgen));
								n++;
							}
						}
					}
				}
				
			}
		}
		
		//System.out.printf("%d method invocations\n", n);
	}

	@SuppressWarnings("unchecked")
	public static void dumpDefinedMethodNames(String filename) throws IOException {
		ZipFile zip = new ZipFile(filename);
		
		for (Enumeration<ZipEntry> ee = (Enumeration<ZipEntry>) zip.entries(); ee.hasMoreElements();) {
			ZipEntry e = ee.nextElement();
			InputStream ein = zip.getInputStream(e);
			if (e.getName().endsWith(".class")) {
				//System.out.println(e.getName());
				ClassParser parser = new ClassParser(ein, e.getName());
				JavaClass klass = parser.parse();
				for (Method m : klass.getMethods()) {
					System.out.println(m.getName());
				}				
			}
		}
		
		//System.out.printf("%d method invocations\n", n);
	}

}
