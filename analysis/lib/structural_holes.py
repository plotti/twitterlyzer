# encoding: utf-8
"""
Functions for ego networks and structural holes.

Original code written by Diederik van Liere and Jasper Voskuilen from
RSM Erasmus University, the Netherlands and contributen to Jung 1.x
This code was ported from JUNG 2.0 (jung.sourceforge.net) and extended
by Diederik van Liere from RSM Erasmus University, the Netherlands and
the Rotman School of Management, University of Toronto.

This module contains the structural hole measures as suggested by Burt, 1992:
- Effective size
- Efficiency
- Network constraint
- Hierarchy

In addition it also calculates ego-density. 

Reference: Burt, Ronald S. (1992) Structural Holes - The Social
Structure of Competition, Cambridge, MA: Harvard University Press
http://books.google.ca/books?hl=en&lr=&id=E6v0cVy8hVIC&oi=fnd&pg=PR7&dq=%22Burt%22+%22Structural+Holes%22+&ots=omMOXb-aPF&sig=fZL_7Ly4N9h805E59QbAXJatkx8#PPR9,M1
"""
#    BSD license.
__author__ = """\n""".join(['Diederik van Liere',
                            'Jasper Voskuilen',
                            'Aric Hagberg <hagberg@lanl.gov>'])
__all__= ['ego_density',
          'effective_size',
          'efficiency',
          'constraint',
          'local_constraint',
          'aggregate_constraint',
          'hierarchy'
          ]

import math
import networkx as nx

# helpers for algorithms

def all_neighbors(G,n):
    # same as neighbors for undirected graphs
    # both in- and out-neighbors for directed graphs
    if G.is_directed():
        nbrs=G.predecessors(n)+G.successors(n)
    else:
        nbrs=G.neighbors(n)
    return nbrs

def mutual_weight(G,u,v):
    try:
        w=G[u][v].get('weight',1)
    except:
        w=0
    try:
        w+=G[v][u].get('weight',1)
    except:
        pass
    return w

def normalized_mutual_weight(G,u,v,max_scaled=False):
    if max_scaled:
        mw=float(max([mutual_weight(G,u,w) for w in all_neighbors(G,u)]))
    else:
        mw=float(sum([mutual_weight(G,u,w) for w in all_neighbors(G,u)]))
    if mw==0:
        return 0
    return mutual_weight(G,u,v)/mw

##############


def ego_density(G,v):
    # Is there a definition that makes sense for weighted graphs?
    H=nx.ego_graph(G,v,center=False,undirected=True)
    return nx.density(H) # multiply by 100 to get percentage


def effective_size(G,n):
    # This treats directed graphs as undirected
    # Could be modified to handle directed graphs differently
    # Ignores weights 
    ndeg=float(G.degree(n)) # number of neighbors (alters)
    E=nx.ego_graph(G,n,center=False,undirected=True) 
    deg=E.degree() # degree of neighbors not including n
    # degree of n - average deg of nbrs
    return ndeg-sum(deg.values())/(ndeg-1.0) 

def efficiency(G,v): 
    return effective_size(G,v)/G.degree(v) 

def constraint(G,v): 
    """
    Burt's constraint measure (equation 2.4, page 55 of Burt,
    1992). Essentially a measure of the extent to which v is invested
    in people who are invested in other of v's alters (neighbors).
    The "constraint" is characterized by a lack of primary holes
    around each neighbor.  Formally: constraint(v) = sum_{w in MP(v),
    w != v} localConstraint(v,w) where MP(v) is the subset of v's
    neighbors that are both predecessors and successors of v.
    """
    if G.is_directed():
        # Intersection of in- and out-neighbors
        nbrs=[u for u in G.successors(v) if u in G.predecessors(v)]
    else:
        nbrs=G.neighbors_iter(v)
    result = 0.0
    for n in nbrs:
        result += local_constraint(G,v,n)
    return result
    
def local_constraint(G, u, v):
    """
    Returns the local constraint on v from a lack of primary holes
    around its neighbor v.  Based on Burt's equation 2.4.  Formally:
    localConstraint(u, v) = ( p(u,v) + ( sum_{w in N(v)} p(u,w) *
    p(w, v) ) )^2 where
    N(v) = v.getNeighbors()
    p(v,w) = normalized mutual edge weight of v and w
    """
    weight = normalized_mutual_weight(G,u,v)
    r=0.0        
    for w in all_neighbors(G,u):
        r += normalized_mutual_weight(G,u,w) * normalized_mutual_weight(G,w,v)
    return (weight + r)**2


def hierarchy(G,v):
    """
    Calculates the hierarchy value for a given vertex.  Returns NaN when
    v's degree is 0, and 1 when v's degree is 1.
    Formally:
    hierarchy(v) = (sum_{v in N(v), w != v} s(v,w) * log(s(v,w))}) / (v.degree() * Math.log(v.degree())
    where
    N(v) = v.getNeighbors()
    s(v,w) = localConstraint(v,w) / (aggregateConstraint(v) / v.degree())
    """
    degv=G.degree(v)
    if degv==0:
        raise NetworkXError("hierarchy not defined for degree zero node %s"%v)
    v_constraint = aggregate_constraint(G,v)
    sl_constraint = 0.0
    numerator = 0.0
    for w in all_neighbors(G,v):
        sl_constraint = degv* local_constraint(G,v, w) /v_constraint 
        numerator += sl_constraint * math.log(sl_constraint)
    return numerator / (degv * math.log(degv))
    

def aggregate_constraint(G,v,organizational_measure=None):
    """
    The aggregate constraint on v.  Based on Burt's equation 2.7.
    Formally: aggregateConstraint(v) = sum_{w in N(v)}
    localConstraint(v,w) * O(w)
    """
    if organizational_measure is None:
        """
        A measure of the organization of individuals within the subgraph
        centered on v.  Burt's text suggests that this is
        in some sense a measure of how "replaceable" v is by
        some other element of this subgraph.  Should be a number in the
        closed interval [0,1].
        The default returns 1.  Users may wish to override this
        method in order to define their own behavior.
        """
        def organizational_measure(G,n):
            return 1.0
    result=0.0
    for w in all_neighbors(G,v):
        result += local_constraint(G,v,w)*organizational_measure(G, w)
    return result

