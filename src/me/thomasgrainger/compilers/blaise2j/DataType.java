package me.thomasgrainger.compilers.blaise2j;


public class DataType {
	private Type t;
	public final static DataType BOOLEAN = new DataType(Type.BOOLEAN);
	public final static DataType FLOAT = new DataType(Type.FLOAT);
	public final static DataType INTEGER = new DataType(Type.INTEGER);
	public DataType(DataType left, DataType right){
		if (left.equals(right)){
			t = left.t;
		} else {
			switch (left.t){
				case BOOLEAN:
					throw new InvalidDataTypeException();
				/*
				 * This is a design decision giving priority to more accurate values
				 */
				case INTEGER:
					if (right.t.equals(Type.BOOLEAN)){
						throw new InvalidDataTypeException();
					} else {
						t=right.t;
					}
					break;
				case FLOAT:
					if (right.t.equals(Type.BOOLEAN)){
						throw new InvalidDataTypeException();
					} else {
						t=left.t;
					}
					break;
			}
		}
	}
	
	public static DataType ensure(DataType target, DataType left,DataType right){
		if (target.equals(left) && DataType.BOOLEAN.equals(left)){
			return target;
		} else {
			throw new InvalidDataTypeException();
		}
	}
	
	public DataType (Type t){
		this.t = t;
	}
	
	public static DataType parseType(String strtype){
		return new DataType(Type.parseType(strtype));
	}
	
	@Override
	public String toString(){
		return t.toString();
	}
	
	
	
	/* (non-Javadoc)
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((t == null) ? 0 : t.hashCode());
		return result;
	}

	/* (non-Javadoc)
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(Object obj) {
		if (this == obj) {
			return true;
		}
		if (obj == null) {
			return false;
		}
		if (!(obj instanceof DataType)) {
			return false;
		}
		DataType other = (DataType) obj;
		if (t != other.t) {
			return false;
		}
		return true;
	}



	public enum Type{
		INTEGER ("int"),
		FLOAT ("double"),
		BOOLEAN ("boolean");
		
		private final String representation;
		Type(String representation){
			this.representation = representation;
		}
		
		@Override
		public String toString(){
			return representation;
		}
		
		public static Type parseType(String type){
			if (type.equals("INTEGER")) {
				return INTEGER;
			} else if (type.equals("FLOAT")){
				return FLOAT;
			} else if (type.equals("BOOLEAN")){
				return BOOLEAN;
			} else return null;
		}
	}
}
