/*
* @(#)ArqMont.java  1.0  30/03/2001
*	
* Aline Vieira de Mello
* Pontif�cia Universidade Cat�lica do Rio Grande do Sul - Faculdade de Inform�tica
*/

/**
* <i>ArqMont</i> implementa a lista que contem as instru��es da arquitetura
* descrita pelo Configurador de Arquiteturas.
*/
public class ArqMont
{
	private NodoArqMont inicio;
	private NodoArqMont fim;
	
	public ArqMont()
	{
		inicio=null;
		fim=null;		
	}	
	
	/**
	* Retorna o apontador para o inicio da lista.
	*/
	public NodoArqMont getInicio() {return inicio;}
	
	/**
	* Retorna o apontador para o fim da lista.
	*/
	public NodoArqMont getFim() {return fim;}
	
	/**
	* Informa ao apontador o inicio da lista.
	*/
	public void setInicio(NodoArqMont n) {inicio=n;}

	/**
	* Informa ao apontador o fim da lista.
	*/
	public void setFim(NodoArqMont n) {fim=n;}
			
	/**
	* Inicializa a lista com os seus apontador para inicio e fim nulls.
	*/
	public void inicializa()
	{
		inicio=null;	
		fim=null;
	}	
	
	/**
	* Inclui um nodo no final da lista.
	*/
	public void inclui(String mneu,String inst,int nclock,String c1,String c2,String c3,String c4,String camp1,String camp2,String camp3,String camp4,String flagDep,int nflag,String[] flags)
	{
		NodoArqMont novo=new NodoArqMont(mneu,inst,nclock,c1,c2,c3,c4,camp1,camp2,camp3,camp4,flagDep,nflag,flags);
		
		if(inicio==null)
		{
			inicio=novo;
			fim=novo;	
		}
		else
		{
			fim.setProx(novo);
			fim=novo;		
		}
	}
	
	/**
	* Retorna o nodo que contem a instru��o, caso contr�rio retorna NULL.
	*/
	public NodoArqMont procuraInstrucao(String inst)
	{
		NodoArqMont aux=inicio;
		while(aux!=null)
		{
			if(aux.getInstrucao().equalsIgnoreCase(inst))
				return aux;
			aux=aux.getProx();	
		}
		return null;
	}
	
	/**
	* Retorna TRUE se o c�digo informado existe na lista e
	* FALSE caso contr�rio.
	*/
	public boolean procuraCodigos(String c1,String c2,String c3,String c4)
	{
		NodoArqMont aux=inicio;
		while(aux!=null)
		{
			if(aux.getCod1().equalsIgnoreCase(c1)&&aux.getCod2().equalsIgnoreCase(c2)&&aux.getCod3().equalsIgnoreCase(c3)&&aux.getCod4().equalsIgnoreCase(c4))
				return true;
			aux=aux.getProx();
		}
		return false;
	}

	/**
	* Retorna TRUE se o nodo que contem a instru��o informada foi exclu�do
	* da lista e FALSE caso a instru��o n�o seja encontrada e portanto, n�o
	* seja exclu�da.
	*/
	public boolean excluir(String inst)
	{
		NodoArqMont aux1,aux2;
		aux1=procuraInstrucao(inst);
		if(aux1!=null)
		{
			if(aux1==inicio && aux1==fim)
			{
				inicio=null;
				fim=null;	
			}
			else if(aux1==inicio)
			{
				inicio=aux1.getProx();
			}
			else
			{	
				aux2=inicio;
				while(aux2.getProx()!=aux1)
					aux2=aux2.getProx();
				aux2.setProx(aux1.getProx());

				if(aux1==fim)
				{
					fim=aux2;
				}
			}
			return true;
		}
		return false;
	}
	
	/**
	* Retorna TRUE se a instru��o informada faz parte da lista de instru��es
	* e FALSE caso contr�rio.
	*/
	public boolean existeInstrucao(String inst)
	{
		NodoArqMont aux=inicio;
		while(aux!=null)
		{
			if(aux.getMneumonico().equalsIgnoreCase(inst))
				return true;
			aux=aux.getProx();	
		}
		return false;
	}
	
	/**
	* Exibe na console todas as instru��es inclu�das na lista.
	*/
	public void exibe()
	{
		System.out.println("LISTA DE INSTRU��ES DA ARQUITETURA DESCRITA");
		
		NodoArqMont aux=inicio;
		while(aux!=null)
		{
			System.out.println("\nMneumonico: "+aux.getMneumonico()+" Instrucao: "+aux.getInstrucao());
			System.out.println("Codigo: "+aux.getCod1()+" "+aux.getCod2()+" "+aux.getCod3()+" "+aux.getCod4());
			System.out.println("Campo: "+aux.getCampo1()+" "+aux.getCampo2()+" "+aux.getCampo3()+" "+aux.getCampo4());
			System.out.println("Flag Dependente: "+aux.getFlag_dep());
			System.out.println("Flag Afetados: ");
			for(int i=0;i<aux.getNflag();i++)
				System.out.println(aux.getFlags(i));
			aux=aux.getProx();	
		}
	}
	
	/**
	* Exibe na console a instru��o informada.
	*/
	public void exibe(String instrucao)
	{
		boolean achei=false;
		
		NodoArqMont aux=inicio;
		while(aux!=null && !achei)
		{
			if(aux.getInstrucao().equalsIgnoreCase(instrucao))
			{
				System.out.println("Mneumonico: "+aux.getMneumonico()+" Instrucao: "+aux.getInstrucao());
				System.out.println("Codigo: "+aux.getCod1()+" "+aux.getCod2()+" "+aux.getCod3()+" "+aux.getCod4());
				System.out.println("Campo: "+aux.getCampo1()+" "+aux.getCampo2()+" "+aux.getCampo3()+" "+aux.getCampo4());
				System.out.println("Flag Dependente: "+aux.getFlag_dep());
				System.out.println("Flag Afetados: ");
				for(int i=0;i<aux.getNflag();i++)
					System.out.println(aux.getFlags(i));
				achei=true;
			}
			aux=aux.getProx();	
		}
	}
}