/*
* @(#)MeuTokenizer.java  1.0  05/05/2001
*	
* Aline Vieira de Mello
* Pontif�cia Universidade Cat�lica do Rio Grande do Sul - Faculdade de Inform�tica
*/
import java.util.*;
	
/**
* <i>MeuTokenizer</i> basea-se na lista de separadores para dividir a linha em
* tokens.
*/
public class MeuTokenizer
{
	private String[] separadores;
	private String linha;
	private Vector tokens;
	private int numerotokens;
	private int posicaolinha;
	private int tamanholinha;
	private int indice;
		
	public MeuTokenizer(String[] separadores,String linha)
	{
		this.separadores=separadores;
		this.linha=linha;
		tokens=new Vector();
		numerotokens=0;
		posicaolinha=0;
		tamanholinha=linha.length();
		indice=0;
		separaLinha();
	}
		
	/**
	* Verifica se o caracter � um separador, se for retorna true.
	*/
	public boolean ehSeparador(String s)
	{
		for(int i=0;i<separadores.length;i++)
		{
			if(separadores[i].equalsIgnoreCase(s))
				return true;
		}
		return false;
	}

	/**
	* Verifica se o caracter � um separador, se for retorna true.
	*/
	public boolean ehSeparador(String[] separadores,String s)
	{
		for(int i=0;i<separadores.length;i++)
		{
			if(separadores[i].equalsIgnoreCase(s))
				return true;
		}
		return false;
	}

	/**
	* L� a linha separado-a em tokens conforme os separadores. 
	*/
	public void separaLinha()
	{	
		while(posicaolinha<tamanholinha)
		{
			String token="";
			while (posicaolinha<tamanholinha && ehSeparador(linha.substring(posicaolinha,posicaolinha+1)))
				posicaolinha++;
			if(posicaolinha<tamanholinha)
			{
				while ((posicaolinha<tamanholinha) && !ehSeparador(linha.substring(posicaolinha,posicaolinha+1)))
				{
						token=token.concat(linha.substring(posicaolinha,posicaolinha+1));
						posicaolinha++;
				}
				numerotokens++;
				tokens.addElement((Object)token);
			}
		}
	}
	
	/**
	* Retira os separadores do tipo Remov�veis.
	* A sequencia de separadores removiveis s�o eliminadas e dentre estas as que 
	* ocorrem entre os tokens s�o substitu�das por UM espa�o em branco caso o 
	* o antecessor for diferente de um separador fixo.
	*
	* Por exemplo:
	*	 sepadoresDel={"\t","\n"} e separadoresFixos={",","(",")"}
	*  linha="      ADD          R12,  R13     "
	* Logo teremos:
	*  linha="ADD R12,R13" 		
	*/
	public String removeBrancos(String[] separadoresDel,String[] separadoresFix,String linha)	
	{
		String linhaRetorno=new String();
		int tamanhoLinha=linha.length();
		int indiceLinha=0;
		boolean separadorFixo=false,separadorDel=false;

				
		while(indiceLinha<tamanhoLinha)
		{
			//Verifica se � separador REMOVIVEIS
			while(indiceLinha<tamanhoLinha && ehSeparador(separadoresDel,linha.substring(indiceLinha,indiceLinha+1)))
			{
				separadorDel=true;
				indiceLinha++;
			}
			
			//Continua se n�o for fim da linha
			if(indiceLinha!=tamanhoLinha)
			{
				//Se n�o est� no in�cio e o �ltimo byte v�lido n�o for um
				//separador Fixo ent�o inclui UM espa�o em branco.
				if(linhaRetorno.length()!=0 && !separadorFixo)
					linhaRetorno=linhaRetorno.concat(" ");
				
				while(indiceLinha<tamanhoLinha && !ehSeparador(separadoresDel,linha.substring(indiceLinha,indiceLinha+1)))
				{
					if(ehSeparador(separadoresFix,linha.substring(indiceLinha,indiceLinha+1)))
					{
						//ultimo byte for um separador Removivel, remove o espa�o em
						//inclu�do no fim da linha indevidamente
						if(separadorDel)
							linhaRetorno=linhaRetorno.substring(0,linhaRetorno.length()-1);

						separadorFixo=true;
						separadorDel=false;
					}
					else
					{
						separadorDel=false;
						separadorFixo=false;
					}
						
					linhaRetorno=linhaRetorno.concat(linha.substring(indiceLinha,indiceLinha+1));
					indiceLinha++;
				}
			}
		}
		return linhaRetorno;	
	}	

	/**
	* Retorna o pr�ximo token da linha.
	*/
	public String nextToken()
	{
		try
		{
			return (String)tokens.elementAt(indice++);
		}catch(Exception e){System.err.println("N�o h� pr�ximo Token.");}
		return null;
	}
	
	/**
	* Retorna o token da linha na posi��o n informada pelo par�metro.
	*/
	public String nextToken(int n)
	{
		try
		{
			return (String)tokens.elementAt(n);
		}catch(Exception e){System.err.println("N�o h� pr�ximo Token.");}
		return null;
	}
	
	/**
	* Retorna o n�mero de tokens da linha.
	*/
	public int countTokens(){return numerotokens;}
}