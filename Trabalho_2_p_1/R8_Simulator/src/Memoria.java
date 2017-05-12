/*
* @(#)Memoria.java  1.0  30/03/2001
*	
* Aline Vieira de Mello
* Pontif�cia Universidade Cat�lica do Rio Grande do Sul - Faculdade de Inform�tica
*/

/**
* <i>Memoria</i> implementa a lista que cont�m as informa��es da mem�ria.
*/
public class Memoria
{
	private NodoMemoria inicio;
	private NodoMemoria fim;
	private Simulador sim;

	public Memoria(Simulador sim)
	{
		this.sim=sim;
		inicializa();
	}

	/**
	* Retorna o nodo da lista que corresponde ao inicio.
	*/
	public NodoMemoria getInicio()	{return inicio;}

	/**
	* Retorna o nodo da lista que corresponde ao fim.
	*/
	public NodoMemoria getFim()	{return fim;}

	/**
	* Atribui um nodo como inicio da lista.
	*/
	public void setInicio(NodoMemoria aux)	{inicio=aux;}
	
	/**
	* Atribui um nodo como fim da lista.
	*/
	public void setFim(NodoMemoria aux)	{fim=aux;}

	/**
	* Inicializa a lista atribuindo null ao inicio e ao fim da mesma.
	*/
	public void inicializa()
	{
		inicio=null;
		fim=null;
	}

	/**
	* Inclui um nodo ao final da lista
	*/
	public void inclui(String pc,String instrucao,String linha)
	{
		NodoMemoria novo=new NodoMemoria(pc,instrucao,linha);
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
	* Retorna o nodo da mem�ria que corresponde ao endere�o do pc.
	*/
	public NodoMemoria getMemoria(String pc)
	{
		NodoMemoria aux=inicio;
		while(aux!=null)
		{
			if(aux.getPc().equals(pc))
				return aux;
			aux=aux.getProx();
		}
		return null;
	}

	/**
	* Retorna o valor que corresponde ao endere�o do pc.
	*/
	public String getInstrucao(String pc)
	{
		NodoMemoria aux=inicio;
		while(aux!=null)
		{
			if(aux.getPc().equals(pc))
				return aux.getInstrucao();
			aux=aux.getProx();
		}
		return "0000";
	}


	/**
	* Atribui um novo valor a um nodo que corresponde ao endere�o do
	* pc ou inclui um novo nodo caso o endere�o n�o exista.
	* pc,inst,label
  */
	public void setMemoria(String[] dado)
	{
	  boolean achei=false;
		NodoMemoria aux=inicio;
		
		while(aux!=null && !achei)
		{
			if(aux.getPc().equalsIgnoreCase(dado[0]))
			{
				achei=true;
				aux.setInstrucao(dado[1]);
			}
			aux=aux.getProx();
		}
		//Se nao encontrou PC, inclui.
		if(!achei)
			inclui(dado[0],dado[1],dado[2]);

		//Inclui na tabela mem�ria
		/*for(int i=0;i<sim.getTamanhoMemoria();i++)
		{
			if((sim.getJanela().getTabelaMemoria().getValueAt(i,1)).equals(pc))
			{
				sim.getJanela().getTabelaMemoria().setValueAt(label,i,0);
				sim.getJanela().getTabelaMemoria().setValueAt(inst,i,2);
				i=sim.getTamanhoMemoria();
			}
		}*/
	}

	/**
	* Exibe todos os nodos inclu�dos na lista.
	*/
	public void exibe()
	{
		System.out.println("Mem�ria");
	
		NodoMemoria aux=inicio;
		while(aux!=null)
		{
			System.out.println("PC:"+aux.getPc()+" Instrucao:"+aux.getInstrucao()+" Linha:"+aux.getLinha());
			aux=aux.getProx();
		}
	}
}